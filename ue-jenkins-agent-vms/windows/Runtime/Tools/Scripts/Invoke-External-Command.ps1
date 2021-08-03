# Helper function for invoking an external utility, with stdin/stdout
# This allows for calling programs that talk directly to stdin/stdout but is also mockable in tests.
#
# Reference: https://stackoverflow.com/a/56821110
function Invoke-External-Command {

	<#
		.SYNOPSIS
		Runs an external program, in a mock-friendly way

    .DESCRIPTION
    This runs a console command. It will not work well with non-console applications.
    Standard Input is fetched from stdin.
    Standard Output is returned from the function, and can be captured in a variable or piped elsewhere.
    If $MergeStderr is set, standard error will be mixed in with the standard output.

    Error messages will sometimes be formatted as this, and printed in red, first message being expanded:
      <commandname> : <message>
        + CategoryInfo          : NotSpecified: (<message>  :String) [], RemoteException
        + FullyQualifiedErrorId : NativeCommandError 
      ... but further stderr prints will be just the messages themselves...
      ... and sometimes the error messages will be printed just as the message itself.
    Stdout and stderr will be interleaved in the order that the application prints to them.

    If you wish to capture the program's output, invoke it like this:
      $CapturedOutput = Invoke-External-ConnectedStdinStdout ...
  #>

    param (
        [Parameter(Mandatory=$true)] [string] $LiteralPath,
        [Parameter(Mandatory=$false)] [string[]] $ArgumentList,
        [Parameter(Mandatory=$false)] [switch] $MergeStderr=$false,
        [Parameter(Mandatory=$false)] [ref] $ExitCode
    )

  if ($MergeStderr) {
    & $LiteralPath $ArgumentList 2>&1
  } else {
    & $LiteralPath $ArgumentList
  }
  $ExitCode.Value = $LASTEXITCODE
}
