. ${PSScriptRoot}\Install-DockerCLI.ps1
. ${PSScriptRoot}\Install-GoogleCloudSDK.ps1
. ${PSScriptRoot}\Install-Plastic.ps1
. ${PSScriptRoot}\Create-PlasticClientConfigLinks.ps1

Write-Host "Installing Docker CLI..."

Install-DockerCLI

Write-Host "Installing Google Cloud SDK..."

Install-GoogleCloudSDK

Write-Host "Installing Plastic SCM..."

Install-Plastic

Write-Host "Creating symlinks for plastic client config files..."

Create-PlasticClientConfigLinks

Write-Host "Done."
