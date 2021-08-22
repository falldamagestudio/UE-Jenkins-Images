
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\SystemConfiguration\Enable-Win32LongPaths.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-CreateServiceUser.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-CreateAgentHostFolders.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallGCELoggingAgent.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallBuildTools-Host.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallBuildTools-Container.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallSCMTools.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallOpenSSHServer.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-RegisterServices.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Applications\Install-AdoptiumOpenJDK.ps1

$ScriptLocation = "${PSScriptRoot}\..\..\..\..\Scripts\Windows\Agents\Services\GCEService-SshAgent-Startup.ps1"

Write-Host "Enabling Win32 Long Paths..."

Enable-Win32LongPaths

$ServiceUserCredential = BuildStep-CreateServiceUser
BuildStep-CreateAgentHostFolders
BuildStep-InstallGCELoggingAgent
BuildStep-InstallBuildTools-Host
BuildStep-InstallBuildTools-Container
BuildStep-InstallSCMTools -UserProfilePath "C:\Users\$($ServiceUserCredential.GetNetworkCredential().UserName)"
BuildStep-InstallOpenSSHServer
BuildStep-RegisterServices -ScriptLocation $ScriptLocation -Credential $ServiceUserCredential

Write-Host "Installing Adoptium OpenJDK..."

Install-AdoptiumOpenJDK


Write-Host "Done."
