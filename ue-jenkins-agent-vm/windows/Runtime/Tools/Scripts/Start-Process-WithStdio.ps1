function Start-Process-WithStdio {

	<#
		.SYNOPSIS
		Start-Process with support for redirecting stdin/stdout/stderr to variables.
        Note that this does not perform 'shell execute', the FilePath should point to
         a real executable; if you want to run a script or similar, then
         call this with FilePath=powershell and Arguments=<your script> + actual args.
	#>

	param (
		[Parameter(Mandatory)] [string] $FilePath,
		[Parameter(Mandatory)] [string[]] $ArgumentList,
		[Parameter(Mandatory=$false)] [string] $StdIn=$null
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

	$Arguments = $ArgumentList | ForEach-Object { "`"$PSItem`"" } | ToArray -Join " "

    $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
    $ProcessInfo.FileName = $FilePath
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
