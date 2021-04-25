. ${PSScriptRoot}\Invoke-External-WithStdio.ps1

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

	$ExitCode, $StdOut, $StdErr = Invoke-External-WithStdio -LiteralPath $Application -StdIn $AgentKey @$ArgumentList

	if ($ExitCode -eq 0) {
        return $StdOut
	} else {
		return $null
    }
}
