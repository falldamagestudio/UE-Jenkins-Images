. ${PSScriptRoot}\..\SystemConfiguration\Register-AutoStartService-PowerShell.ps1

function BuildStep-RegisterServices {

	param (
		[Parameter(Mandatory)] [string] $ScriptLocation,
		[Parameter(Mandatory)] [PSCredential] $Credential
	)

    $DefaultFolders = Import-PowerShellDataFile "${PSScriptRoot}\DefaultBuildStepSettings.psd1" -ErrorAction Stop

    $VMStartupScriptLocation = "${PSScriptRoot}\..\Agents\Services\GCEService-VM-Startup.ps1"

    Write-Host "Registering VM setup script as autostarting..."

    Register-AutoStartService-PowerShell -ServiceName $DefaultFolders.JenkinsVMStartupServiceName -ScriptLocation $VMStartupScriptLocation -Credential $Credential

    Write-Host "Registering Jenkins Agent script as autostarting..."

    Register-AutoStartService-PowerShell -ServiceName $DefaultFolders.JenkinsAgentServiceName -ScriptLocation $ScriptLocation -Credential $Credential
}
