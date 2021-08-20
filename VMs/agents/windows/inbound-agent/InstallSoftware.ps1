. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\SystemConfiguration\Enable-Win32LongPaths.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-CreateAgentHostFolders.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallGCELoggingAgent.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallBuildTools-Host.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallBuildTools-Container.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallSCMTools.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Applications\Install-AdoptiumOpenJDK.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Applications\Install-JenkinsRemotingAgent.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Agents\Services\Register-AutoStartService-JenkinsAgent.ps1

$DefaultFolders = Import-PowerShellDataFile "${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\DefaultFolders.psd1"

$ScriptLocation = "${PSScriptRoot}\..\..\..\..\Scripts\Windows\Agents\Services\GCEService-InboundAgent.ps1"

Write-Host "Enabling Win32 Long Paths..."

Enable-Win32LongPaths

BuildStep-CreateAgentHostFolders
BuildStep-InstallGCELoggingAgent
BuildStep-InstallBuildTools-Host
BuildStep-InstallBuildTools-Container
BuildStep-InstallSCMTools

Write-Host "Installing Adoptium OpenJDK..."

Install-AdoptiumOpenJDK

Write-Host "Installing Jenkins Remoting Agent..."

Install-JenkinsRemotingAgent -Path $JenkinsAgentFolder

Write-Host "Registering Jenkins Agent script as autostarting..."

Register-AutoStartService-JenkinsAgent -ScriptLocation $ScriptLocation

Write-Host "Done."
