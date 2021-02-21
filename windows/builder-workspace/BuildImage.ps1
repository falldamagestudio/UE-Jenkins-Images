param (
	[Parameter(Mandatory=$true)][string]$ImageName,
	[Parameter(Mandatory=$true)][string]$ImageTag
)

class DockerBuildException : Exception {
	$ExitCode

	DockerBuildException([int] $exitCode) : base("docker build exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

# Install DirectX Redistributable
# This is the only officially supported way to get hold of xinput1_3.dll & d3dcompiler_43.dll
#  (the .DLL files need to be present within the container, but the redist installer cannot
#   be executed within the container - so we run the installer on the host OS, and we can then
#   fetch the DLLs from the host filesystem, and provide them to the container build process)

. ${PSScriptRoot}\Install-DirectXRedistributable.ps1

Install-DirectXRedistributable

# Provide xinput1_3.dll & d3dcompiler_43.dll from host OS to the container build process

Copy-Item C:\Windows\System32\xinput1_3.dll Container -ErrorAction Stop
Copy-Item C:\Windows\System32\d3dcompiler_43.dll Container -ErrorAction Stop

# Provide opengl32.dll & glu32.dll from host OS to the container build process
# (these are part of Windows Server, but not Windows Server Core)

Copy-Item C:\Windows\System32\opengl32.dll Container -ErrorAction Stop
Copy-Item C:\Windows\System32\glu32.dll Container -ErrorAction Stop

# Build container image

& docker build -t "${ImageName}:${ImageTag}" -f ue-jenkins-buildtools-windows.Dockerfile .
$DockerExitCode = $LASTEXITCODE
if ($DockerExitcode -ne 0) {
	throw [DockerBuildException]::new($DockerExitCode)
}
