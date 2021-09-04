function Install-JenkinsSwarmAgent {

    param (
		[Parameter(Mandatory)] [string] $Path
    )

	$ToolsAndVersions = Import-PowerShellDataFile -Path "${PSScriptRoot}\ToolsAndVersions.psd1" -ErrorAction Stop

    $TargetFile = "${Path}\swarm-agent.jar"

    #Download Jenkins Swarm agent jar, and place it in a default location
    Invoke-WebRequest -UseBasicParsing -Uri $ToolsAndVersions.JenkinsSwarmAgentDownloadUrl -OutFile $TargetFile -ErrorAction Stop
}
