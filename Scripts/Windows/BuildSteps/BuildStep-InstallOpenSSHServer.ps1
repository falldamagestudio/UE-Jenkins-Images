. ${PSScriptRoot}\..\Applications\Install-Chocolatey.ps1
. ${PSScriptRoot}\..\Applications\Install-OpenSSHServer.ps1

function BuildStep-InstallOpenSSHServer {

    Write-Host "Installing Chocolatey..."

    Install-Chocolatey

    Write-Host "Installing OpenSSH Server..."

    Install-OpenSSHServer

    Set-Service -Name "sshd" -StartupType Manual
}
