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

	Start-Process -FilePath $NssmLocation -ArgumentList $NssmArguments -Wait -NoNewWindow
}
