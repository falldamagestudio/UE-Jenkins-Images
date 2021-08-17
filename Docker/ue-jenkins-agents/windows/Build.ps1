param (
	[Parameter(Mandatory=$true)][string]$GceRegion,
	[Parameter(Mandatory=$true)][string]$Dockerfile,
	[Parameter(Mandatory=$true)][string]$AgentKey,
	[Parameter(Mandatory=$true)][string]$ImageName,
	[Parameter(Mandatory=$true)][string]$ImageTag
)

. ${PSScriptRoot}\..\..\..\Scripts\Windows\SystemConfiguration\Resize-PartitionToMaxSize.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\Applications\Authenticate-DockerForGoogleArtifactRegistry.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\Helpers\Run-Tests.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\ImageBuilder\Host\Install-TestDependencies.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\ImageBuilder\Host\Build-DockerImage.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\ImageBuilder\Host\Push-DockerImage.ps1

Write-Host "Resizing C: partition to use all available disk space..."

Resize-PartitionToMaxSize -DriveLetter C

Write-Host "Installing test dependencies..."

Install-TestDependencies

Write-Host "Running tests for Powershell scripts..."

Run-Tests -Path "${PSScriptRoot}\..\..\..\Scripts"
Run-Tests -Path "${PSScriptRoot}\..\..\..\Docker"

Write-Host "Setting up Docker authentication..."

Authenticate-DockerForGoogleArtifactRegistry -AgentKey ${AgentKey} -Region ${GceRegion}

Write-Host "Building image..."

Build-Image -Dockerfile $Dockerfile -ImageName ${ImageName} -ImageTag ${ImageTag}

Write-Host "Pushing image to registry..."

Push-Image -ImageName ${ImageName} -ImageTag ${ImageTag}

Write-Host "Done."
