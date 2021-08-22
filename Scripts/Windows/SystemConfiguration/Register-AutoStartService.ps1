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
		[Parameter(Mandatory)] [string] $ServiceName,
		[Parameter(Mandatory)] [string] $Program,
		[Parameter(Mandatory=$false)] [string[]] $ArgumentList,
		[Parameter(Mandatory=$false)] [PSCredential] $Credential
	)

	$NssmLocation = "${PSScriptRoot}\nssm.exe"

	# Register service

	$NssmInstallArguments = @(
		"install"
		$ServiceName
		$Program
	) 

	if ($ArgumentList -ne $null) {
		$NssmInstallArguments += $ArgumentList
	}

	$Process = Start-Process -FilePath $NssmLocation -ArgumentList $NssmInstallArguments -NoNewWindow -Wait -PassThru

	if ($Process.ExitCode -ne 0) {
		throw [NssmException]::new($Process.ExitCode)
	}

	# If credentials were provided, change user which the program runs under

	if ($Credential) {

		$NssmSetUserArguments = @(
			"set"
			$ServiceName
			"ObjectName"
			$Credential.UserName
			$Credential.GetNetworkCredential().Password
		) 
	
		$Process = Start-Process -FilePath $NssmLocation -ArgumentList $NssmSetUserArguments -NoNewWindow -Wait -PassThru
	
		if ($Process.ExitCode -ne 0) {
			throw [NssmException]::new($Process.ExitCode)
		}
	}
}
