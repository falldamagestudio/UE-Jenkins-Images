param (
	[Parameter(Mandatory=$true)][string]$GceRegion,
	[Parameter(Mandatory=$true)][string]$Dockerfile,
	[Parameter(Mandatory=$true)][string]$AgentKeyFile,
	[Parameter(Mandatory=$true)][string]$ImageName,
	[Parameter(Mandatory=$true)][string]$ImageTag
)

. ${PSScriptRoot}\..\..\..\Scripts\Windows\SystemConfiguration\Resize-PartitionToMaxSize.ps1

. ${PSScriptRoot}\..\..\..\Scripts\Windows\ImageBuilder\Host\Setup-DockerRegistryAuthentication.ps1

. ${PSScriptRoot}\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallBuildTools-Host.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\ImageBuilder\Copy-SystemDLLs.ps1

. ${PSScriptRoot}\..\..\..\Scripts\Windows\ImageBuilder\Host\Build-DockerImage.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\ImageBuilder\Host\Push-DockerImage.ps1

Write-Host "Resizing C: partition to use all available disk space..."

Resize-PartitionToMaxSize -DriveLetter C

Write-Host "Setting up Docker authentication..."

# Due to unknown reasons, Authenticate-DockerForGoogleArtifactRegistry fails with an
#  error message like this when the windows-docker-image-builder drives:
#    Error response from daemon: Get https://europe-west1-docker.pkg.dev/v2/: unauthorized: authentication failed
# This error does not occur if manually logging in via WinRM to an interactive session and performing authentication,
#  even to the same machine, even if running the same script.
# While we would like to use the Authenticate-DockerForGoogleArtifactRegistry flow in all circumstances,
#  that is not feasible when using windows-docker-image-builder.
#
# Authenticate-DockerForGoogleArtifactRegistry -AgentKey (Get-Content -Raw -Encoding ASCII -Path $AgentKeyFile -ErrorAction Stop) -Region $GceRegion

# Instead, we use this version - it installs a separate tool for authentication, but
#  has proven to work.
Setup-DockerRegistryAuthentication -AgentKeyFile $AgentKeyFile -GceRegion $GceRegion

BuildStep-InstallBuildTools-Host

# Provide DirectX related DLLs from host OS to the container build process
# Provide opengl32.dll & glu32.dll from host OS to the container build process
#  (these are part of Windows Server, but not Windows Server Core)

Copy-SystemDLLs -SourceFolder "C:\Windows\System32" -TargetFolder $PSScriptRoot

Write-Host "Building image..."

Build-DockerImage -Dockerfile $Dockerfile -ImageName $ImageName -ImageTag $ImageTag -Context .

Write-Host "Pushing image to registry..."

Push-DockerImage -ImageName $ImageName -ImageTag $ImageTag

Write-Host "Done."
