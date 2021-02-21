param (
	[Parameter(Mandatory=$true)][string]$ImageName,
	[Parameter(Mandatory=$true)][string]$ImageTag
)

class DockerPushException : Exception {
	$ExitCode

	DockerPushException([int] $exitCode) : base("docker push exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

# Push built container image to remote registry

& docker push "${ImageName}:${ImageTag}"
$DockerExitCode = $LASTEXITCODE
if ($DockerExitcode -ne 0) {
	throw [DockerPushException]::new($DockerExitCode)
}
