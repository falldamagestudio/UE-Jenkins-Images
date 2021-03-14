Write-Host "Installing script start"

. ${PSScriptRoot}\Install-Plastic.ps1

Write-Host "Installing Plastic SCM..."

Install-Plastic

Write-Host "Done."
