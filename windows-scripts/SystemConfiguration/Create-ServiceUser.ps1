function Create-ServiceUser {

	<#
		.SYNOPSIS
		Creates a Windows account, suitable for running services:
        It is a member of the local administrators group, and it does not allow remote login
	#>

	param (
		[Parameter(Mandatory)] [string] $Name
	)

    New-LocalUser -Name $Name -NoPassword -AccountNeverExpires -UserMayNotChangePassword -ErrorAction Stop | Out-Null
    Set-LocalUser -Name $Name -PasswordNeverExpires $true -ErrorAction Stop
    Add-LocalGroupMember -Group "Administrators" -Member $Name -ErrorAction Stop

    # Following steps are only needed if you would like to use key-based authentication for SSH.
    # Following step is needed so that new user will show up in HKLM.
    #Write-Output "Simulating new user login..."
    #$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Name,$password
    #Start-Process cmd /c -WindowStyle Hidden -Credential $cred -ErrorAction SilentlyContinue

}
