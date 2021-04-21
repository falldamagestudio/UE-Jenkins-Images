class RunJenkinsAgentException : Exception {
	$Operation
	$ExitCode

	RunJenkinsAgentException([string] $operation, [int] $exitCode) : base("docker ${operation} exited with code ${exitCode}") { $this.Operation = $operation; $this.ExitCode = $exitCode }
}

function Run-JenkinsAgent {

	<#
		.SYNOPSIS
		Runs Jenkins Agent in a Docker container
	#>

	param (
		[Parameter(Mandatory)] [string] $JenkinsAgentFolder,
		[Parameter(Mandatory)] [string] $JenkinsWorkspaceFolder,
		[Parameter(Mandatory)] [string] $JenkinsURL,
		[Parameter(Mandatory)] [string] $JenkinsSecret,
		[Parameter(Mandatory)] [string] $AgentImageURL,
		[Parameter(Mandatory)] [string] $AgentName
	)

	$Arguments = @(
		"run"
		"--rm"
		"--name","jenkins-agent"
		"--mount","type=bind,source=${JenkinsAgentFolder},destination=${JenkinsAgentFolder}"
		"--mount","type=bind,source=${JenkinsWorkspaceFolder},destination=${JenkinsWorkspaceFolder}"
		"--mount","type=bind,source=${env:USERPROFILE}\.docker,destination=C:\users\jenkins\.docker"
		"-v","\\.\pipe\docker_engine:\\.\pipe\docker_engine"
		$AgentImageUrl
		"-Url",$JenkinsUrl
		"-WorkDir",$JenkinsAgentFolder
		"-Secret",$JenkinsSecret
		"-Name",$AgentName
		"-WebSocket"
	)

	try {

		# Fetch Docker agent image
		$Process = Start-Process -FilePath "docker" -ArgumentList "pull",$AgentImageUrl -NoNewWindow -Wait -PassThru -ErrorAction Stop
		if ($Process.ExitCode -ne 0) {
			throw [RunJenkinsAgentException]::new("run", $Process.ExitCode)
		}

		# Start Docker agent
		$Process = Start-Process -FilePath "docker" -ArgumentList $Arguments -NoNewWindow -Wait -PassThru -ErrorAction Stop
		if ($Process.ExitCode -ne 0) {
			throw [RunJenkinsAgentException]::new("run", $Process.ExitCode)
		}

	} finally {
		Start-Process -FilePath "docker" -ArgumentList "stop","jenkins-agent" -NoNewWindow -Wait -ErrorAction SilentlyContinue
	}
}
