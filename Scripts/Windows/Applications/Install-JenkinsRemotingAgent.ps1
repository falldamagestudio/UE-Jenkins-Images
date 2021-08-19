class JenkinsRemotingAgentContentHashException : Exception {
    $ExpectedHash
    $ActualHash

	JenkinsRemotingAgentContentHashException($expectedHash, $actualHash) : base("File hash mismatch when downloading Jenkins remoting jars; expected = ${expectedHash}, actual = ${actualHash}") { $this.ExpectedHash = $expectedHash; $this.ActualHash = $actualHash }
}

function Install-JenkinsRemotingAgent {

    param (
		[Parameter(Mandatory)] [string] $Path
    )

    $DownloadUrl = "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/4.7/remoting-4.7.jar"
    $TargetFile = "${Path}\agent.jar"

    # Download Jenkins remoting agent jar, and place it in a default location
    Invoke-WebRequest -UseBasicParsing -Uri $DownloadUrl -OutFile $TargetFile

    # Validate content hash for remoting agent jar
    $ExpectedHash = Invoke-RestMethod -Uri "${DownloadURL}.sha1"
    $ActualHash = (Get-FileHash $TargetFile -Algorithm SHA1).Hash

    if ($ExpectedHash -ne $ActualHash) {
        throw [JenkinsRemotingAgentContentHashException]::new($ExpectedHash, $ActualHash)
    }
}
