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
        [Parameter(Mandatory=$false)] [string[]] $ArgumentList
    )

  # Invoke command, and pipe the command's stdout to the host output. Without the piping, the stdout output will be caught and returned as function pipeline output instead.
  # Any writes to the command's stderr will be displayed as such, for the first message:
  #  <commandname> : <message>
  #      + CategoryInfo          : NotSpecified: (<message>  :String) [], RemoteException
  #      + FullyQualifiedErrorId : NativeCommandError 
  # ... and further stderr prints will be just the messages themselves, but still colored in red.
  #
  # Stdout and stderr will be interleaved in the correct order.

  & $LiteralPath $ArgumentList | Out-Host

  return $LASTEXITCODE
}
