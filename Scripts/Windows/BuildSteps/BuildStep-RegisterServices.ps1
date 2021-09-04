. ${PSScriptRoot}\..\SystemConfiguration\Register-AutoStartService-PowerShell.ps1

function BuildStep-RegisterServices {

	param (
		[Parameter(Mandatory)] [string] $ScriptLocation,
		[Parameter(Mandatory)] [PSCredential] $Credential
	)

    $VMSettings = Import-PowerShellDataFile "${PSScriptRoot}\VMSettings.psd1" -ErrorAction Stop

    $VMStartupScriptLocation = "${PSScriptRoot}\..\Agents\Services\GCEService-VM-Startup.ps1"

    Write-Host "Registering VM setup script as autostarting..."

    Register-AutoStartService-PowerShell -ServiceName $VMSettings.JenkinsVMStartupServiceName -ScriptLocation $VMStartupScriptLocation -Credential $Credential

    Write-Host "Registering Jenkins Agent script as autostarting..."

    Register-AutoStartService-PowerShell -ServiceName $VMSettings.JenkinsAgentServiceName -ScriptLocation $ScriptLocation -Credential $Credential
}
