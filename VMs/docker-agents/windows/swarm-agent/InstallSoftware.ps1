. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\SystemConfiguration\Enable-Win32LongPaths.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-CreateAgentHostFolders.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallGCELoggingAgent.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Agents\Services\Register-AutoStartService-JenkinsAgent.ps1

$ScriptLocation = "${PSScriptRoot}\..\..\..\..\Scripts\Windows\Agents\Services\GCEService-DockerSwarmAgent.ps1"

Write-Host "Enabling Win32 Long Paths..."

Enable-Win32LongPaths

BuildStep-CreateAgentHostFolders
BuildStep-InstallGCELoggingAgent

Write-Host "Registering Jenkins Agent script as autostarting..."

Register-AutoStartService-JenkinsAgent -ScriptLocation $ScriptLocation

Write-Host "Done."
