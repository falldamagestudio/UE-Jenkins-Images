class NssmException : Exception {
	$ExitCode

	NssmException([int] $exitCode) : base("nssm exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Register-AutoStartService {

	<#
		.SYNOPSIS
		Installs a service as autostarting.
	#>

	param (
		[Parameter(Mandatory)] [string] $NssmLocation,
		[Parameter(Mandatory)] [string] $ServiceName,
		[Parameter(Mandatory)] [string] $Program,
		[Parameter(Mandatory=$false)] [string[]] $ArgumentList
	)

	$NssmArguments = @(
		"install"
		$ServiceName
		$Program
	) 

	if ($ArgumentList -ne $null) {
		$NssmArguments += $ArgumentList
	}

	$Process = Start-Process -FilePath $NssmLocation -ArgumentList $NssmArguments -NoNewWindow -Wait -PassThru

	if ($Process.ExitCode -ne 0) {
		throw [NssmException]::new($Process.ExitCode)
	}
}
