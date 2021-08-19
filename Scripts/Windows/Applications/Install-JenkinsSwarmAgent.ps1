function Install-JenkinsSwarmAgent {

    param (
		[Parameter(Mandatory)] [string] $Path
    )

    # The official download URL is on the format,
    # https://repo.jenkins-ci.org/native/releases/org/jenkins-ci/plugins/swarm-client/<version>/swarm-client-<version>.jar
    # but when we hit that directly we get 404 back
    # Therefore we use an artifactory-related URL instead - it appears to work better
    $DownloadUrl = "https://repo.jenkins-ci.org/artifactory/releases/org/jenkins-ci/plugins/swarm-client/3.25/swarm-client-3.25.jar"
    $TargetFile = "${Path}\swarm-agent.jar"

    #Download Jenkins Swarm agent jar, and place it in a default location
    Invoke-WebRequest -UseBasicParsing -Uri $DownloadUrl -OutFile $TargetFile
}
