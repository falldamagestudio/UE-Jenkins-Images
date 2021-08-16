function Add-WindowsDefenderExclusionRule {

	<#
		.SYNOPSIS
		Adds an exclusion rule for Windows Defender; it will no longer scan the specified folder
	#>

	param (
		[Parameter(Mandatory)] [string] $Folder
	)

	Set-MpPreference -ExclusionPath $Folder -Force
}
