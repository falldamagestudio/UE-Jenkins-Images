. ${PSScriptRoot}\Run-DockerAgent.ps1

function Run-DockerSwarmAgent {

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

		# Docker run parameters

		"--rm"
		"--name","jenkins-agent"
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

		# Swarm client settings; reference: https://plugins.jenkins.io/swarm/#documentation

		# Use Websocket protocol
		"-webSocket"
		"-executors","${NumExecutors}"
		"-labels",$Labels
		# Only build jobs with label expressions matching this node's labels
		"-mode","exclusive"
		"-master",$JenkinsUrl
		"-workDir",$JenkinsAgentFolder
		"-username",$AgentUsername
		"-password",$AgentAPIToken
		# Do not add a random suffix to the node name
		"-disableClientsUniqueId"
		# When going online, if the node already exists, then delete the previous node
		# In some scenarios, a failed client startup results in the Swarm plugin creating the node, but not
		#  deleting it afterward. With this setting we are ensured that subsequent starts of the same
		#  client will not fail (because the node already exists).
		# On the other hand, this will cause weird situations if multiple clients are started with the
		#  same exact name. That is a smaller problem, so we choose to have this flag present
		"-deleteExistingClients"
		# Fail if ${JenkinsAgentFolder} is missing
		"-failIfWorkDirIsMissing"
		"-name",$AgentName

	)

	Run-DockerAgent -AgentImageURL $AgentImageURL -AgentRunArguments $Arguments
}
