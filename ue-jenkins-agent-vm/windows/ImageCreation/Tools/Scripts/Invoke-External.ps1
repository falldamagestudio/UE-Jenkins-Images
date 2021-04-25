# Helper function for invoking an external utility (executable).
# The raison d'être for this function is to allow 
# calls to external executables via their *full paths* to be mocked in Pester.
#
# Reference: https://stackoverflow.com/a/56821110
function Invoke-External {

	<#
		.SYNOPSIS
		Runs an external program, in a mock-friendly way
	#>

    param (
        [Parameter(Mandatory=$true)] [string] $LiteralPath,
        [Parameter(ValueFromRemainingArguments=$true)] [string[]] $PassThruArgs
    )

  & $LiteralPath $PassThruArgs

  return $LASTEXITCODE
}
