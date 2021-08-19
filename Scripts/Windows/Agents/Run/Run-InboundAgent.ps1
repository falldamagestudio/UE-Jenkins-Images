function Run-InboundAgent {

	<#
		.SYNOPSIS
		Runs Jenkins Inbound Agent
	#>

	param (
		[Parameter(Mandatory)] [string] $JenkinsAgentFolder,
		[Parameter(Mandatory)] [string] $JenkinsWorkspaceFolder,
		[Parameter(Mandatory)] [string] $JenkinsURL,
		[Parameter(Mandatory)] [string] $JenkinsSecret,
		[Parameter(Mandatory)] [string] $AgentName
	)

	# TODO: utilize $JenkinsWorkspaceFolder

	$AgentJarLocation = "${JenkinsAgentFolder}\agent.jar"

	$Arguments = @(
		"-cp"
		$AgentJarLocation
		"hudson.remoting.jnlp.Main"
		"-headless"
		"-url",$JenkinsUrl
		"-workDir",$JenkinsAgentFolder
		"-webSocket"
		$JenkinsSecret
		$AgentName)

	$JavaHome = $env:JAVA_HOME

	# if java home is defined, use it
	$JAVA_BIN = "java.exe"
	if (![System.String]::IsNullOrWhiteSpace($JavaHome)) {
		$JAVA_BIN = "$JavaHome/bin/java.exe"
	}

    Start-Process -FilePath $JAVA_BIN -Wait -NoNewWindow -ArgumentList $AgentArguments
}
