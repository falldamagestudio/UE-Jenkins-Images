. ${PSScriptRoot}\Run-DockerAgent.ps1

function Run-DockerSshAgent {

	<#
		.SYNOPSIS
		Runs Jenkins SSH Agent in a Docker container
	#>

	param (
		[Parameter(Mandatory)] [string] $JenkinsAgentFolder,
		[Parameter(Mandatory)] [string] $JenkinsWorkspaceFolder,
		[Parameter(Mandatory)] [string] $PlasticConfigFolder,
		[Parameter(Mandatory)] [string] $AgentImageURL,
		[Parameter(Mandatory)] [string] $AgentJarFolder,
		[Parameter(Mandatory)] [string] $AgentJarFile
	)

	$Arguments = @(
		"--rm"
		"--name","jenkins-agent"
		"-i"
		# Share agent jar folder with containers
		"--mount","type=bind,source=${AgentJarFolder},destination=${AgentJarFolder}"
		# Share Jenkins agent work folder with containers
		"--mount","type=bind,source=${JenkinsAgentFolder},destination=${JenkinsAgentFolder}"
		# Share Jenkins workspace folder with containers
		"--mount","type=bind,source=${JenkinsWorkspaceFolder},destination=${JenkinsWorkspaceFolder}"
		# Share Plastic SCM config folder with containers
		"--mount","type=bind,source=${PlasticConfigFolder},destination=${PlasticConfigFolder}"
		# Share docker auth for Google Artifact Registry with docker CLI users inside containers
		"--mount","type=bind,source=${env:USERPROFILE}\.docker,destination=C:\users\jenkins\.docker"
		# Enable docker CLI users inside containers to communicate with Docker daemon
		"-v","\\.\pipe\docker_engine:\\.\pipe\docker_engine"
		$AgentImageUrl
        "java","-jar",$AgentJarFile
		"-text"
		"-workDir",$JenkinsAgentFolder

	)

	Run-DockerAgent -AgentImageURL $AgentImageURL -AgentRunArguments $Arguments
}
