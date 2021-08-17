class DockerBuildException : Exception {
	$ExitCode

	DockerBuildException([int] $exitCode) : base("docker build exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Build-DockerImage {

	param (
		[Parameter(Mandatory=$true)][string]$Dockerfile,
		[Parameter(Mandatory=$true)][string]$ImageName,
		[Parameter(Mandatory=$true)][string]$ImageTag,
		[Parameter(Mandatory=$true)][string]$Context
	)

	# Build container image

	& docker build -f $Dockerfile -t "${ImageName}:${ImageTag}" $Context
	$DockerExitCode = $LASTEXITCODE
	if ($DockerExitcode -ne 0) {
		throw [DockerBuildException]::new($DockerExitCode)
	}
}
