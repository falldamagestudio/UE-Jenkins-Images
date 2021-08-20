. ${PSScriptRoot}\..\Applications\Install-DirectXRedistributable.ps1

function BuildStep-InstallBuildTools-Host {

    Write-Host "Installing DirectX redistributable..."

    # Install DirectX Redistributable
    # This is the only officially supported way to get hold of DirectX DLLs
    #  (the .DLL files need to be present within the container, but the redist installer cannot
    #   be executed within the container - so we run the installer on the host OS, and we can then
    #   fetch the DLLs from the host filesystem, and provide them to the container build process)
    
    Install-DirectXRedistributable
    
}