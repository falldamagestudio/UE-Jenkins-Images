. ${PSScriptRoot}\..\..\..\Scripts\Windows\SystemConfiguration\Enable-Win32LongPaths.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\Applications\Install-DockerCLI.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\Applications\Install-GoogleCloudSDK.ps1
. ${PSScriptRoot}\..\..\..\Scripts\Windows\BuildSteps\BuildStep-InstallSCMTools.ps1

Write-Host "Enabling Win32 Long Paths..."

Enable-Win32LongPaths

Write-Host "Installing Docker CLI..."

Install-DockerCLI

Write-Host "Installing Google Cloud SDK..."

Install-GoogleCloudSDK

BuildStep-InstallSCMTools -UserProfilePath $env:USERPROFILE

Write-Host "Done."
