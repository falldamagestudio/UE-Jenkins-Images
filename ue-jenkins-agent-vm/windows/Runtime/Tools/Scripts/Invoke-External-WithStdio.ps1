function Invoke-External-WithStdio {

	<#
		.SYNOPSIS
		Invoke-External with support for redirecting stdin/stdout/stderr to variables.
        Note that this does not perform 'shell execute', the LiteralPath should point to
         a real executable; if you want to run a script or similar, then
         call this with LiteralPath=powershell and ArgumentList=<your script> + actual args.
	#>

	param (
		[Parameter(Mandatory)] [string] $LiteralPath,
		[Parameter(Mandatory=$false)] [string] $StdIn=$null,
        [Parameter(Mandatory=$false)] [string[]] $ArgumentList=$null
	)

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

	$Arguments = $null
	if ($ArgumentList -ne $null) {
		$Arguments = $ArgumentList | ForEach-Object { "`"$PSItem`"" } | ToArray -Join " "
	}

    $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
    $ProcessInfo.FileName = $LiteralPath
    $ProcessInfo.RedirectStandardInput = ($StdIn -ne $null)
    $ProcessInfo.RedirectStandardOutput = $true
    $ProcessInfo.RedirectStandardError = $true
    $ProcessInfo.UseShellExecute = $false
    $ProcessInfo.Arguments = $Arguments
    $Process = New-Object System.Diagnostics.Process
    $Process.StartInfo = $ProcessInfo
    $Process.Start() | Out-Null
    if ($StdIn -ne $null) {
        $Process.StandardInput.Write($StdIn)
        $Process.StandardInput.Close()
    }
    $Process.WaitForExit() | Out-Null
    $StdOut = $Process.StandardOutput.ReadToEnd()
    $StdErr = $Process.StandardError.ReadToEnd()
    return $Process.ExitCode, $StdOut, $StdErr
}
