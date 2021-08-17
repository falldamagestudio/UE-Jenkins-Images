param (
	[Parameter(Mandatory=$true)][string]$GceRegion,
	[Parameter(Mandatory=$true)][string]$Dockerfile,
	[Parameter(Mandatory=$true)][string]$AgentKeyFile,
	[Parameter(Mandatory=$true)][string]$ImageName,
	[Parameter(Mandatory=$true)][string]$ImageTag
)

. ${PSScriptRoot}\..\..\..\Scripts\Windows\SystemConfiguration\Resize-PartitionToMaxSize.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\Helpers\Run-Tests.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\ImageBuilder\Host\Install-TestDependencies.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\ImageBuilder\Host\Build-DockerImage.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\ImageBuilder\Host\Push-DockerImage.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\ImageBuilder\Host\Setup-DockerRegistryAuthentication.ps1

Write-Host "Resizing C: partition to use all available disk space..."

Resize-PartitionToMaxSize -DriveLetter C

#Write-Host "Installing test dependencies..."
#
#Install-TestDependencies
#
#Write-Host "Running tests for Powershell scripts..."
#
#Run-Tests -Path "${PSScriptRoot}\..\..\..\Scripts"

# HACK
#Write-Host "Sleeping for an hour..."
#Start-Sleep 3600

Write-Host "Setting up Docker authentication..."

# Due to unknown reasons, this fails with an error message like this when the windows-docker-image-builder drives:
#  Error response from daemon: Get https://europe-west1-docker.pkg.dev/v2/: unauthorized: authentication failed
# This error does not occur if manually logging in via WinRM to an interactive session and performing authentication.
#
#Authenticate-DockerForGoogleArtifactRegistry -AgentKey (Get-Content -Raw -Encoding ASCII -Path $AgentKeyFile -ErrorAction Stop) -Region $GceRegion

# Instead, we use this version - it uses a different process that works also for the image builder
Setup-DockerRegistryAuthentication -AgentKeyFile $AgentKeyFile -GceRegion $GceRegion

Write-Host "Building image..."

Build-DockerImage -Dockerfile $Dockerfile -ImageName $ImageName -ImageTag $ImageTag -Context .

Write-Host "Pushing image to registry..."

Push-DockerImage -ImageName $ImageName -ImageTag $ImageTag

Write-Host "Done."
