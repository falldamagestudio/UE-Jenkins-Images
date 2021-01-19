. ${PSScriptRoot}\Install-VisualStudioBuildTools.ps1

. ${PSScriptRoot}\Install-DebuggingToolsForWindows.ps1

. ${PSScriptRoot}\Install-XInputDLL.ps1

Write-Host "Installing Visual Studio Build Tools..."

Install-VisualStudioBuildTools

Write-Host "Installing Debugging Tools for Windows..."

# This provides PDBCOPY.EXE which is used when packaging up the Engine
Install-DebuggingToolsForWindows

Write-Host "Installing XINPUT1_3.DLL..."

# This provides XINPUT1_3.DLL which is used when running the C++ apps (UE4Editor-Cmd.exe for example), even in headless mode
# Normally, you would install the DirectX Redistributable to get this DLL onto the system. However, the DirectX redist cannot be installed
#  within a Windows Server Core container (the installer will error out with exit code -9). Because of this, the surrounding VM
#  will have to provide the DLL as-is and this is then copied to the appropriate location.
Install-XInputDLL
# Install-DirectXRedistributable

Write-Host "Done."
