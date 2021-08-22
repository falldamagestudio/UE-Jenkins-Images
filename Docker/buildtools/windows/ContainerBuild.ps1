. ${PSScriptRoot}\..\..\..\Scripts\Windows\SystemConfiguration\Enable-Win32LongPaths.ps1

. ${PSScriptRoot}\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallBuildTools-Container.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallSCMTools.ps1

. ${PSScriptRoot}\..\..\..\Scripts\Windows\ImageBuilder\Copy-SystemDLLs.ps1

Write-Host "Enabling Win32 Long Paths..."

Enable-Win32LongPaths

BuildStep-InstallBuildTools-Container
BuildStep-InstallSCMTools -UserProfilePath $env:USERPROFILE

Write-Host "Installing additional system DLLs..."
    
# This provides DirectX and OpenGL DLLs which are used when running the C++ apps (UE4Editor-Cmd.exe for example), even in headless mode
# Normally, you would install these by running various installers,  but these can for various
#  reasons not be installed from within a Windows Server Core container. Instead, these are
#  explicitly provided from the host OS side.
Copy-SystemDLLs -SourceFolder $PSScriptRoot -TargetFolder "C:\Windows\System32"
# Install-DirectXRedistributable

Write-Host "Done."
