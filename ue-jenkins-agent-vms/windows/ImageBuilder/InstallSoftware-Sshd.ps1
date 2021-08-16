. ${PSScriptRoot}\..\Scripts\Windows\SystemConfiguration\Create-ServiceUser.ps1
. ${PSScriptRoot}\..\Scripts\Windows\Applications\Install-Chocolatey.ps1
. ${PSScriptRoot}\..\Scripts\Windows\Applications\Install-OpenSSHServer.ps1

Write-Host "Creating Jenkins user..."

Create-ServiceUser -Name "Jenkins"

Write-Host "Installing Chocolatey..."

Install-Chocolatey

Write-Host "Installing OpenSSH Server..."

Install-OpenSSHServer

Write-Host "Done."
