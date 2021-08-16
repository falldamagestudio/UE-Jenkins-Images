. ${PSScriptRoot}\..\Helpers\Invoke-External-WithStdio.ps1

class AuthenticateDockerForGoogleArtifactRegistryException : Exception {
	$ExitCode

	AuthenticateDockerForGoogleArtifactRegistryException([int] $exitCode) : base("docker login -u _json_key <...> exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Authenticate-DockerForGoogleArtifactRegistry {

	<#
		.SYNOPSIS
		Configures Docker to use JSON key file authentication when accessing a particular Google Artifact Registry region
	#>

	param (
		[Parameter(Mandatory)] [string] $AgentKey,
		[Parameter(Mandatory)] [string] $Region
	)

	$Application = "powershell"

	$ArgumentList = @(
		"docker"
		"login"
		"-u","_json_key"
		"--password-stdin"
		"${Region}-docker.pkg.dev"
	)

	$ExitCode,$StdOut,$StdErr = Invoke-External-WithStdio -LiteralPath $Application -StdIn $AgentKey -ArgumentList $ArgumentList 

    if ($ExitCode -ne 0) {
		throw [AuthenticateDockerForGoogleArtifactRegistryException]::new($ExitCode)
    }
}
