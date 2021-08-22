. ${PSScriptRoot}\..\SystemConfiguration\New-ServiceUser.ps1

function BuildStep-CreateServiceUser {

    $DefaultFolders = Import-PowerShellDataFile "${PSScriptRoot}\DefaultBuildStepSettings.psd1" -ErrorAction Stop

    Write-Host "Creating service user..."

    $Credential = New-ServiceUser -Name $DefaultFolders.ServiceUserName

    Write-Host "BuildStep-CreateServiceUser: Credential type: $($Credential.GetType())"

    $Credential
}