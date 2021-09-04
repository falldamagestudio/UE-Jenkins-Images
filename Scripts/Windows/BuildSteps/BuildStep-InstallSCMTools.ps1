. ${PSScriptRoot}\..\Applications\Install-Git.ps1
. ${PSScriptRoot}\..\Applications\Install-Plastic.ps1
. ${PSScriptRoot}\..\Applications\Create-PlasticClientConfigLinks.ps1

function BuildStep-InstallSCMTools {

    param (
        [Parameter(Mandatory)] [string] $UserProfilePath
    )

    $DefaultFolders = Import-PowerShellDataFile "${PSScriptRoot}\..\VMSettings.psd1"

    Write-Host "Installing Git for Windows..."

    Install-Git

    Write-Host "Installing Plastic SCM..."

    Install-Plastic

    Write-Host "Creating user-specific symlinks for plastic client config files..."

    $Plastic4SourceFolderLocation = "${UserProfilePath}\AppData\Local\plastic4"

    Create-PlasticClientConfigLinks -SourceFolder $Plastic4SourceFolderLocation -TargetFolder $DefaultFolders.PlasticConfigFolder
}