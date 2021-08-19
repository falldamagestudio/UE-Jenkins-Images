function Install-JenkinsSwarmAgent {

    param (
		[Parameter(Mandatory)] [string] $Path
    )

    $DownloadUrl = "https://repo.jenkins-ci.org/native/releases/org/jenkins-ci/plugins/swarm-client/3.25/swarm-client-3.25.jar"
    $TargetFile = "${Path}\swarm-agent.jar"

    # Download Jenkins Swarm agent jar, and place it in a default location
    Invoke-WebRequest -UseBasicParsing -Uri $DownloadUrl -OutFile $TargetFile
}
