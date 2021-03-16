. ${PSScriptRoot}\Install-Plastic.ps1
. ${PSScriptRoot}\Create-PlasticClientConfigLinks.ps1

Write-Host "Installing Plastic SCM..."

Install-Plastic

Write-Host "Creating symlinks for plastic client config files..."

Create-PlasticClientConfigLinks

Write-Host "Done."
