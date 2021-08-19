. ${PSScriptRoot}\..\Applications\Install-Git.ps1
. ${PSScriptRoot}\..\Applications\Install-Plastic.ps1
. ${PSScriptRoot}\..\Applications\Create-PlasticClientConfigLinks.ps1

function Install-SCMTools {

    $PlasticConfigFolder = "C:\PlasticConfig"

    Write-Host "Installing Git for Windows..."

    Install-Git

    Write-Host "Installing Plastic SCM..."

    Install-Plastic

    Write-Host "Creating config folder for Plastic SCM..."

    New-Item -ItemType Directory -Path $PlasticConfigFolder -ErrorAction Stop | Out-Null

    Write-Host "Creating symlinks for plastic client config files..."

    Create-PlasticClientConfigLinks
}