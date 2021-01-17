function Install-XInputDLL {

	$TargetFolder = "C:\Windows\System32"
	$DLLName = "XINPUT1_3.DLL"

	$SourceLocation = (Join-Path $PSScriptRoot $DLLName)
	$TargetLocation = (Join-Path $TargetFolder $DLLName -ErrorAction Stop)

	Copy-Item -Path $SourceLocation -Destination $TargetLocation -ErrorAction Stop
}
