. ${PSScriptRoot}\..\SystemConfiguration\New-ServiceUser.ps1

function BuildStep-CreateServiceUser {

    $VMSettings = Import-PowerShellDataFile "${PSScriptRoot}\..\VMSettings.psd1" -ErrorAction Stop

    Write-Host "Creating service user..."

    $Credential = New-ServiceUser -Name $VMSettings.ServiceUserName

    Write-Host "BuildStep-CreateServiceUser: Credential type: $($Credential.GetType())"

    $Credential
}