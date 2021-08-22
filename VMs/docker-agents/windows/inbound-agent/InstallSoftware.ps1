. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\SystemConfiguration\Enable-Win32LongPaths.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-CreateServiceUser.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-CreateAgentHostFolders.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallGCELoggingAgent.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallOpenSSHServer.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-RegisterServices.ps1

$ScriptLocation = "${PSScriptRoot}\..\..\..\..\Scripts\Windows\Agents\Services\GCEService-DockerInboundAgent.ps1"

Write-Host "Enabling Win32 Long Paths..."

Enable-Win32LongPaths

$ServiceUserCredential = BuildStep-CreateServiceUser
BuildStep-CreateAgentHostFolders
BuildStep-InstallGCELoggingAgent
BuildStep-InstallOpenSSHServer
BuildStep-RegisterServices -ScriptLocation $ScriptLocation -Credential $ServiceUserCredential

Write-Host "Done."
