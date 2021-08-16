. ${PSScriptRoot}\SystemConfiguration\Enable-Win32LongPaths.ps1

. ${PSScriptRoot}\Applications\Install-VisualStudioBuildTools.ps1

. ${PSScriptRoot}\Applications\Install-DebuggingToolsForWindows.ps1

. ${PSScriptRoot}\ImageBuilder\Container\Install-SystemDLLs.ps1

. ${PSScriptRoot}\Applications\Install-VC2010RedistributableX64.ps1

. ${PSScriptRoot}\Applications\Install-Plastic.ps1

. ${PSScriptRoot}\Applications\Create-PlasticClientConfigLinks.ps1

Write-Host "Enabling Win32 Long Paths..."

Enable-Win32LongPaths

Write-Host "Installing Visual Studio Build Tools..."

Install-VisualStudioBuildTools

Write-Host "Installing Debugging Tools for Windows..."

# This provides PDBCOPY.EXE which is used when packaging up the Engine
Install-DebuggingToolsForWindows

Write-Host "Installing additional system DLLs..."

# This provides DirectX and OpenGL DLLs which are used when running the C++ apps (UE4Editor-Cmd.exe for example), even in headless mode
# Normally, you would install these by running various installers,  but these can for various
#  reasons not be installed from within a Windows Server Core container. Instead, these are
#  explicitly provided from the host OS side.
Install-SystemDLLs
# Install-DirectXRedistributable

Write-Host "Installing VC++ 2010 Redistributable (x64)..."

# This provides MSVCP100.DLL & MSVCR100.DLL which is used by Engine/Binaries/ThirdParty/QualComm/Win64/TextureConverter.dll
#  which in turn is loaded by UE4Editor-Cmd.exe
Install-VC2010RedistributableX64

Write-Host "Installing Plastic SCM..."

Install-Plastic

Write-Host "Creating symlinks for plastic client config files..."

Create-PlasticClientConfigLinks

Write-Host "Done."
