. ${PSScriptRoot}\Start-Process-WithStdio.ps1

function Get-GCESecret {

	<#
		.SYNOPSIS
		Reads the value of a GCE secret.
	#>

	param (
		[Parameter(Mandatory=$true)][string]$Key
	)

	$Application = "powershell"

	$ArgumentList = @(
		"gcloud"
		"secrets"
		"versions"
		"access"
		"latest"
		"--secret=${Key}"
	)

	$ExitCode, $StdOut, $StdErr = Start-Process-WithStdio -FilePath $Application -ArgumentList $ArgumentList -StdIn $AgentKey

	if ($ExitCode -eq 0) {
        return $StdOut
	} else {
		return $null
    }
}
