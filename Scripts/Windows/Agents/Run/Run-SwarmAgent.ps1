function Run-SwarmAgent {

	<#
		.SYNOPSIS
		Runs Jenkins Swarm Agent
	#>

	param (
		[Parameter(Mandatory)] [string] $JenkinsAgentFolder,
		[Parameter(Mandatory)] [string] $JenkinsWorkspaceFolder,
		[Parameter(Mandatory)] [string] $JenkinsURL,
		[Parameter(Mandatory)] [string] $AgentUsername,
		[Parameter(Mandatory)] [string] $AgentAPIToken,
		[Parameter(Mandatory)] [int] $NumExecutors,
		[Parameter(Mandatory)] [string] $Labels,
		[Parameter(Mandatory)] [string] $AgentName
	)

	# TODO: utilize $JenkinsWorkspaceFolder

	$AgentJarLocation = "${JenkinsAgentFolder}\swarm-agent.jar"

	$Arguments = @(

		# Java parameters

		"-jar"
		$AgentJarLocation

		# Swarm client settings; reference: https://plugins.jenkins.io/swarm/#documentation

		"-master",$JenkinsUrl
		"-workDir",$JenkinsAgentFolder
		"-username",$AgentUsername
		"-password",$AgentAPIToken
		"-executors",$NumExecutors
		"-labels","""${Labels}"""
		# Use Websocket protocol
		"-webSocket"
		# Only build jobs with label expressions matching this node's labels
		"-mode","exclusive"
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
		"-name",$AgentName)

	$JavaHome = $env:JAVA_HOME

	# if java home is defined, use it
	$JAVA_BIN = "java.exe"
	if (![System.String]::IsNullOrWhiteSpace($JavaHome)) {
		$JAVA_BIN = "$JavaHome/bin/java.exe"
	}

	Write-Host $JAVA_BIN $Arguments

    Start-Process -FilePath $JAVA_BIN -Wait -NoNewWindow -ArgumentList $Arguments
}
