function Install-JenkinsSwarmAgent {

    param (
		[Parameter(Mandatory)] [string] $Path
    )

    $DownloadUrl = "https://repo.jenkins-ci.org/native/releases/org/jenkins-ci/plugins/swarm-client/3.25/swarm-client-3.25.jar"
    $TargetFile = "${Path}\swarm-agent.jar"

    # Download Jenkins Swarm agent jar, and place it in a default location
    #Invoke-WebRequest -UseBasicParsing -Uri $DownloadUrl -OutFile $TargetFile
    #
    # HACK: include the jar within the repo, since the download URL seems to return 404 when being hit it directly
    Copy-Item -Path "${PSScriptRoot}\..\..\..\VMs\stuff\swarm-client-3.25.jar" -Destination $TargetFile
}
