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
		"-jar"
		$AgentJarLocation
		"-url",$JenkinsUrl
		"-workDir",$JenkinsAgentFolder
		"-username",$AgentUsername
		"-password",$AgentAPIToken
		"-executors",$NumExecutors
		"-labels","""${Labels}"""
		"-webSocket"
		"-name",$AgentName)

	$JavaHome = $env:JAVA_HOME

	# if java home is defined, use it
	$JAVA_BIN = "java.exe"
	if (![System.String]::IsNullOrWhiteSpace($JavaHome)) {
		$JAVA_BIN = "$JavaHome/bin/java.exe"
	}

    Start-Process -FilePath $JAVA_BIN -Wait -NoNewWindow -ArgumentList $AgentArguments
}
