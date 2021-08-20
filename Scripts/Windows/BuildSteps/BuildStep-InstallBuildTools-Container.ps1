. ${PSScriptRoot}\..\Applications\Install-VisualStudioBuildTools.ps1
. ${PSScriptRoot}\..\Applications\Install-DebuggingToolsForWindows.ps1
. ${PSScriptRoot}\..\Applications\Install-VC2010RedistributableX64.ps1

function BuildStep-InstallBuildTools-Container {

    Write-Host "Installing Visual Studio Build Tools..."

    Install-VisualStudioBuildTools
    
    Write-Host "Installing Debugging Tools for Windows..."
    
    # This provides PDBCOPY.EXE which is used when packaging up the Engine
    Install-DebuggingToolsForWindows
    
    Write-Host "Installing VC++ 2010 Redistributable (x64)..."
    
    # This provides MSVCP100.DLL & MSVCR100.DLL which is used by Engine/Binaries/ThirdParty/QualComm/Win64/TextureConverter.dll
    #  which in turn is loaded by UE4Editor-Cmd.exe
    Install-VC2010RedistributableX64
    
}