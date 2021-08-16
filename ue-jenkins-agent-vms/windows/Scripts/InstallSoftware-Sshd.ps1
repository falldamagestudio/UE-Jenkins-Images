. ${PSScriptRoot}\..\windows-scripts\SystemConfiguration\Create-ServiceUser.ps1
. ${PSScriptRoot}\..\windows-scripts\Applications\Install-Chocolatey.ps1
. ${PSScriptRoot}\..\windows-scripts\Applications\Install-OpenSSHServer.ps1

Write-Host "Creating Jenkins user..."

Create-ServiceUser -Name "Jenkins"

Write-Host "Installing Chocolatey..."

Install-Chocolatey

Write-Host "Installing OpenSSH Server..."

Install-OpenSSHServer

Write-Host "Done."
