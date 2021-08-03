. ${PSScriptRoot}\Run-DockerAgent.ps1

function Run-SwarmAgent {

	<#
		.SYNOPSIS
		Runs Jenkins Swarm Agent in a Docker container
	#>

	param (
		[Parameter(Mandatory)] [string] $JenkinsAgentFolder,
		[Parameter(Mandatory)] [string] $JenkinsWorkspaceFolder,
		[Parameter(Mandatory)] [string] $PlasticConfigFolder,
		[Parameter(Mandatory)] [string] $JenkinsURL,
		[Parameter(Mandatory)] [string] $AgentUsername,
		[Parameter(Mandatory)] [string] $AgentAPIToken,
		[Parameter(Mandatory)] [string] $AgentImageURL,
		[Parameter(Mandatory)] [int] $NumExecutors,
		[Parameter(Mandatory)] [string] $Labels,
		[Parameter(Mandatory)] [string] $AgentName
	)

	$Arguments = @(
		"--rm"
		"--name","jenkins-agent"
		# Share Jenkins agent work folder with containers
		"--mount","type=bind,source=${JenkinsAgentFolder},destination=${JenkinsAgentFolder}"
		# Share Jenkins workspace folder with containers
		"--mount","type=bind,source=${JenkinsWorkspaceFolder},destination=${JenkinsWorkspaceFolder}"
		# Share Plastic SCM config folder with containers
		"--mount","type=bind,source=${PlasticConfigFolder},destination=C:\Users\Jenkins\AppData\Local\plastic4"
		# Share docker auth for Google Artifact Registry with docker CLI users inside containers
		"--mount","type=bind,source=${env:USERPROFILE}\.docker,destination=C:\users\jenkins\.docker"
		# Enable docker CLI users inside containers to communicate with Docker daemon
		"-v","\\.\pipe\docker_engine:\\.\pipe\docker_engine"
		$AgentImageUrl
		# Use Websocket protocol
		"-webSocket"
		"-executors","${NumExecutors}"
		"-labels",$Labels
		# Only build jobs with label expressions matching this node
		"-mode","exclusive"
		"-master",$JenkinsUrl
		"-workDir",$JenkinsAgentFolder
		"-username",$AgentUsername
		"-password",$AgentAPIToken
		"-disableClientsUniqueId"
		"-name",$AgentName

	)

	Run-DockerAgent -AgentImageURL $AgentImageURL -AgentRunArguments $Arguments
}
