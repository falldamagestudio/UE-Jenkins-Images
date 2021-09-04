function Install-JenkinsSwarmAgent {

    param (
		[Parameter(Mandatory)] [string] $Path
    )

	$ToolsAndVersions = Import-PowerShellDataFile -Path "${PSScriptRoot}\ToolsAndVersions.psd1" -ErrorAction Stop

    $TargetFile = "${Path}\swarm-agent.jar"

    # Download Jenkins Swarm agent jar, and place it in a default location
    # We specify a blank UserAgent, because the default user agent makes JFrog's repository server
    #  assume that this is an interactive browser - and therefore, it checks for JavaScript support
    #  - and fails us because of lack thereof
    Invoke-WebRequest -UseBasicParsing -UserAgent "" -Uri $ToolsAndVersions.JenkinsSwarmAgentDownloadUrl -OutFile $TargetFile -ErrorAction Stop
}
