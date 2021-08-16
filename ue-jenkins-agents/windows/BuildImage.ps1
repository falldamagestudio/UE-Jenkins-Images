param (
	[Parameter(Mandatory=$true)][string]$Dockerfile,
	[Parameter(Mandatory=$true)][string]$ImageName,
	[Parameter(Mandatory=$true)][string]$ImageTag
)

class DockerBuildException : Exception {
	$ExitCode

	DockerBuildException([int] $exitCode) : base("docker build exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

# Build container image

& docker build -f $Dockerfile -t "${ImageName}:${ImageTag}" ..\..
$DockerExitCode = $LASTEXITCODE
if ($DockerExitcode -ne 0) {
	throw [DockerBuildException]::new($DockerExitCode)
}
