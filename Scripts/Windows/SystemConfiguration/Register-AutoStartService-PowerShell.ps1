. ${PSScriptRoot}\Register-AutoStartService.ps1

class RegisterAutoStartServicePowerShellException : Exception {
	$ScriptLocation

	RegisterAutoStartServicePowerShellException([string] $scriptLocation) : base("Register-AutoStartService-PowerShell must be called with the location of an existing script file; ${scriptLocation} does not exist") { $this.ScriptLocation = $scriptLocation }
}

function Register-AutoStartService-PowerShell {

	<#
		.SYNOPSIS
		Installs a PowerShell script as autostarting
	#>

	param (
		[Parameter(Mandatory)] [string] $ServiceName,
		[Parameter(Mandatory)] [string] $ScriptLocation,
		[Parameter(Mandatory=$false)] [PSCredential] $Credential
	)

	if (!(Test-Path $ScriptLocation)) {
		throw [RegisterAutoStartServicePowerShellException]::new($ScriptLocation)
	}

    Register-AutoStartService -ServiceName $ServiceName -Program "powershell" -ArgumentList @($ScriptLocation) -Credential $Credential
}
