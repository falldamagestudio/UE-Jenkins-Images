class JenkinsRemotingAgentContentHashException : Exception {
    $ExpectedHash
    $ActualHash

	JenkinsRemotingAgentContentHashException($expectedHash, $actualHash) : base("File hash mismatch when downloading Jenkins remoting jars; expected = ${expectedHash}, actual = ${actualHash}") { $this.ExpectedHash = $expectedHash; $this.ActualHash = $actualHash }
}

function Install-JenkinsRemotingAgent {

    param (
		[Parameter(Mandatory)] [string] $Path
    )

	$ToolsAndVersions = Import-PowerShellDataFile -Path "${PSScriptRoot}\ToolsAndVersions.psd1" -ErrorAction Stop

    $TargetFile = "${Path}\agent.jar"

    # Download Jenkins remoting agent jar, and place it in a default location
    Invoke-WebRequest -UseBasicParsing -Uri $ToolsAndVersions.JenkinsRemotingAgentDownloadUrl -OutFile $TargetFile

    # Validate content hash for remoting agent jar
    $ExpectedHash = Invoke-RestMethod -Uri "$($ToolsAndVersions.JenkinsRemotingAgentDownloadUrl).sha1"
    $ActualHash = (Get-FileHash $TargetFile -Algorithm SHA1).Hash

    if ($ExpectedHash -ne $ActualHash) {
        throw [JenkinsRemotingAgentContentHashException]::new($ExpectedHash, $ActualHash)
    }
}
