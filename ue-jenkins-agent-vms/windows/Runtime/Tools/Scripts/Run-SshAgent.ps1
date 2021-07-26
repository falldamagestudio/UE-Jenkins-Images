. ${PSScriptRoot}\Invoke-External-PrintStdout.ps1

class RunSshAgentException : Exception {
	$Operation
	$ExitCode

	RunSshAgentException([string] $operation, [int] $exitCode) : base("docker ${operation} exited with code ${exitCode}") { $this.Operation = $operation; $this.ExitCode = $exitCode }
}

function Run-SshAgent {

	<#
		.SYNOPSIS
		Runs Jenkins SSH Agent in a Docker container
	#>

	param (
		[Parameter(Mandatory)] [string] $JenkinsAgentFolder,
		[Parameter(Mandatory)] [string] $JenkinsWorkspaceFolder,
		[Parameter(Mandatory)] [string] $PlasticConfigFolder,
		[Parameter(Mandatory)] [string] $AgentImageURL,
		[Parameter(Mandatory)] [string] $SlaveJarFolder,
		[Parameter(Mandatory)] [string] $SlaveJarFile
	)

	$Arguments = @(
		"run"
		"--rm"
		"--name","jenkins-agent"
		"-i"
		# Share slave jar folder with containers
		"--mount","type=bind,source=${SlaveJarFolder},destination=${SlaveJarFolder}"
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
        "java","-jar",$SlaveJarFile
		"-text"
		"-workDir",$JenkinsAgentFolder

	)

	try {

		# Fetch Docker agent image
		$ExitCode = Invoke-External-PrintStdout -LiteralPath "docker" -ArgumentList @("pull", $AgentImageUrl)
		if ($ExitCode -ne 0) {
			throw [RunSshAgentException]::new("pull", $ExitCode)
		}

		# Start Docker agent
		& "docker" @Arguments
#		$ExitCode = Invoke-External-PrintStdout -LiteralPath "docker" -ArgumentList $Arguments
#		if ($ExitCode -ne 0) {
#			throw [RunSshAgentException]::new("run", $ExitCode)
#		}

	} finally {
		try {
			Invoke-External-PrintStdout -LiteralPath "docker" -ArgumentList @("stop", "jenkins-agent")
		} catch {
			# Ignore errors here, it is a cleanup path anyway
		}
	}
}
