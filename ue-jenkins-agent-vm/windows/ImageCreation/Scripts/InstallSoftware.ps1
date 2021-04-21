. ${PSScriptRoot}\..\Tools\Scripts\Enable-Win32LongPaths.ps1
. ${PSScriptRoot}\..\Tools\Scripts\Add-WindowsDefenderExclusionRule.ps1

Write-Host "Enabling Win32 Long Paths..."

Enable-Win32LongPaths

Write-Host "Creating folders for Jenkins..."

New-Item -ItemType Directory -Path C:\J
New-Item -ItemType Directory -Path C:\W

Write-Host "Adding Windows Defender exclusion rule for Jenkins-related folders..."

Add-WindowsDefenderExclusionRule -Folder C:\J
Add-WindowsDefenderExclusionRule -Folder C:\W

Write-Host "Done."
