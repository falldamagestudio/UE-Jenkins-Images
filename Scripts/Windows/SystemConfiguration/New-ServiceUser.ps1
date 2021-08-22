. $PSScriptRoot\New-RandomPassword.ps1

function New-ServiceUser {

    <#
        .SYNOPSIS
        Creates a Windows account, suitable for running services:
        It is a member of the local administrators group
        It has a randomly-generated password, and is therefore not usable for
          remote login via WinRM (but could be accessible via SSH)
        It has a profile folder in the typical location (C:\Users\<username>)

        Returns a PSCredential that represents user + password
    #>

    param (
        [Parameter(Mandatory)] [string] $Name
    )

    $Password = New-RandomPassword

    Import-Module -Name "${PSScriptRoot}\CreateProfile\CreateProfile\CreateProfile.psm1" -ErrorAction Stop

    New-Profile -UserName $Name -Password $Password -ErrorAction Stop | Out-Null

    Add-LocalGroupMember -Group "Administrators" -Member $Name -ErrorAction Stop

    $SecureStringPassword = ConvertTo-SecureString $Password -AsPlainText -Force -ErrorAction Stop

    $Credential = [System.Management.Automation.PSCredential]::new("${env:COMPUTERNAME}\${Name}", $SecureStringPassword)

    $Credential
}
