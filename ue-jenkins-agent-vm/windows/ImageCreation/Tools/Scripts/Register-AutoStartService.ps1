. ${PSScriptRoot}\Invoke-External.ps1

function Register-AutoStartService {

	<#
		.SYNOPSIS
		Installs a service as autostarting.
	#>

	param (
		[Parameter(Mandatory)] [string] $NssmLocation,
		[Parameter(Mandatory)] [string] $ServiceName,
		[Parameter(Mandatory)] [string] $Program,
		[Parameter(ValueFromRemainingArguments)] [string[]] $Arguments
	)

	$NssmArguments = @(
		"install"
		$ServiceName
		$Program
	) 

	if ($Arguments -ne $null) {
		$NssmArguments += $Arguments
	}

	$ExitCode = Invoke-External -LiteralPath $NssmLocation @$NssmArguments

	if ($ExitCode -ne 0) {
		throw "nssm.exe exited with exit code $ExitCode"
	}
}
