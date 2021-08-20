. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\SystemConfiguration\Enable-Win32LongPaths.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-CreateAgentHostFolders.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallGCELoggingAgent.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\SystemConfiguration\Create-ServiceUser.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Applications\Install-Chocolatey.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Applications\Install-OpenSSHServer.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Agents\Services\Register-AutoStartService-JenkinsAgent.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Agents\Services\Install-JavaShim-DockerSshAgent.ps1

$ScriptLocation = "${PSScriptRoot}\..\..\..\..\Scripts\Windows\Agents\Services\GCEService-DockerSshAgent-Startup.ps1"


Write-Host "Enabling Win32 Long Paths..."

Enable-Win32LongPaths

BuildStep-CreateAgentHostFolders
BuildStep-InstallGCELoggingAgent

Write-Host "Creating Jenkins user..."

Create-ServiceUser -Name "Jenkins"

Write-Host "Installing Chocolatey..."

Install-Chocolatey

Write-Host "Installing OpenSSH Server..."

Install-OpenSSHServer

Write-Host "Registering Jenkins Agent script as autostarting..."

Register-AutoStartService-JenkinsAgent -ScriptLocation $ScriptLocation

Write-Host "Installing Java shim for Docker SSH agent..."

Install-JavaShim-DockerSshAgent

Write-Host "Done."
