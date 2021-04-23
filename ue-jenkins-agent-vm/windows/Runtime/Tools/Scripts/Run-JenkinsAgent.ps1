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
		# Share Jenkins agent work folder with containers
		"--mount","type=bind,source=${JenkinsAgentFolder},destination=${JenkinsAgentFolder}"
		# Share Jenkins workspace folder with containers
		"--mount","type=bind,source=${JenkinsWorkspaceFolder},destination=${JenkinsWorkspaceFolder}"
		# Share Application Default Credentials with applications inside containers
		"--mount","type=bind,source=${env:APPDATA}\gcloud,destination=C:\Users\jenkins\AppData\Roaming\gcloud"
		# Share docker auth for Google Artifact Registry with docker CLI users inside containers
		"--mount","type=bind,source=${env:USERPROFILE}\.docker,destination=C:\users\jenkins\.docker"
		# Enable docker CLI users inside containers to communicate with Docker daemon
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
