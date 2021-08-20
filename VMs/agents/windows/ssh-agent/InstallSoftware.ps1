
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\SystemConfiguration\Enable-Win32LongPaths.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-CreateAgentHostFolders.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallGCELoggingAgent.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallBuildTools-Host.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallBuildTools-Container.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallSCMTools.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\SystemConfiguration\Create-ServiceUser.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Applications\Install-Chocolatey.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Applications\Install-OpenSSHServer.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Applications\Install-AdoptiumOpenJDK.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Agents\Services\Register-AutoStartService-JenkinsAgent.ps1

$ScriptLocation = "${PSScriptRoot}\..\..\..\..\Scripts\Windows\Agents\Services\GCEService-SshAgent-Startup.ps1"

Write-Host "Enabling Win32 Long Paths..."

Enable-Win32LongPaths

BuildStep-CreateAgentHostFolders
BuildStep-InstallGCELoggingAgent
BuildStep-InstallBuildTools-Host
BuildStep-InstallBuildTools-Container
BuildStep-InstallSCMTools

Write-Host "Creating Jenkins user..."

Create-ServiceUser -Name "Jenkins"

Write-Host "Installing Chocolatey..."

Install-Chocolatey

Write-Host "Installing OpenSSH Server..."

Install-OpenSSHServer

Write-Host "Installing Adoptium OpenJDK..."

Install-AdoptiumOpenJDK

Write-Host "Registering Jenkins Agent script as autostarting..."

Register-AutoStartService-JenkinsAgent -ScriptLocation $ScriptLocation

Write-Host "Done."
