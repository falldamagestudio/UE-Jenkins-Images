. ${PSScriptRoot}\Install-VisualStudioBuildTools.ps1

. ${PSScriptRoot}\Install-DebuggingToolsForWindows.ps1

. ${PSScriptRoot}\Install-SystemDLLs.ps1

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

Write-Host "Done."
