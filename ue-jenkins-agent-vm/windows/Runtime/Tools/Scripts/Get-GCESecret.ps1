function Get-GCESecret {

	<#
		.SYNOPSIS
		Reads the value of a GCE secret.
	#>

	param (
		[Parameter(Mandatory=$true)][string]$Key
	)

	function fStartProcess([string]$sProcess,[string]$sArgs,[ref]$sSTDOUT,[ref]$sSTDERR)
	{
		$oProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
		$oProcessInfo.FileName = $sProcess
		$oProcessInfo.RedirectStandardError = $true
		$oProcessInfo.RedirectStandardOutput = $true
		$oProcessInfo.UseShellExecute = $false
		$oProcessInfo.Arguments = $sArgs
		$oProcess = New-Object System.Diagnostics.Process
		$oProcess.StartInfo = $oProcessInfo
		$oProcess.Start() | Out-Null
		$oProcess.WaitForExit() | Out-Null
		$sSTDOUT.Value = $oProcess.StandardOutput.ReadToEnd()
		$sSTDERR.Value = $oProcess.StandardError.ReadToEnd()
		return $oProcess.ExitCode
	}

	function ToArray
	{
		begin
		{
			$output = @();
		}
		process
		{
			$output += $_;
		}
		end
		{
			return ,$output;
		}
	}

	$Application = "powershell"

	$ArgumentList = @(
		"gcloud"
		"secrets"
		"versions"
		"access"
		"latest"
		"--secret=${Key}"
	)

	$Arguments = $ArgumentList | ForEach-Object { "`"$PSItem`"" } | ToArray -Join " "

	$stdOut = $null
	$stdErr = $null

	$exitCode = fStartProcess -sProcess $Application -sArgs $Arguments -sSTDOUT ([ref]$stdOut) -sSTDERR ([ref]$stdErr)
	if ($exitCode -eq 0) {
        return $stdOut
	} else {
		return $null
    }
}
