. ${PSScriptRoot}\..\..\Helpers\Invoke-External-Command.ps1

class RunDockerAgentException : Exception {
	$Operation
	$ExitCode

	RunDockerAgentException([string] $operation, [int] $exitCode) : base("docker ${operation} exited with code ${exitCode}") { $this.Operation = $operation; $this.ExitCode = $exitCode }
}

function Run-DockerAgent {

	<#
		.SYNOPSIS
		Runs Jenkins Agent in a Docker container
	#>

	param (
		[Parameter(Mandatory)] [string] $AgentImageUrl,
		[Parameter(Mandatory)] [string[]] $AgentRunArguments
	)

	try {
		# Fetch Docker agent image
		$ExitCode = 0
		Invoke-External-Command -LiteralPath "docker" -ArgumentList @("pull", $AgentImageUrl) -ExitCode ([ref]$ExitCode)
		if ($ExitCode -ne 0) {
			throw [RunDockerAgentException]::new("pull", $ExitCode)
		}

		# Start Docker agent
		$ExitCode = 0
		Invoke-External-Command -LiteralPath "docker" -ArgumentList (@("run") + $AgentRunArguments) -ExitCode ([ref]$ExitCode)
		if ($ExitCode -ne 0) {
			throw [RunDockerAgentException]::new("run", $ExitCode)
		}

	} finally {
		try {
			Invoke-External-Command -LiteralPath "docker" -ArgumentList @("stop", "jenkins-agent")
		} catch {
			# Ignore errors here, it is a cleanup path anyway
		}
	}
}
