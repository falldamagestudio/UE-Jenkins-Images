. ${PSScriptRoot}\..\Tools\Scripts\Enable-Win32LongPaths.ps1
. ${PSScriptRoot}\..\Tools\Scripts\Add-WindowsDefenderExclusionRule.ps1

Write-Host "Enabling Win32 Long Paths..."

Enable-Win32LongPaths

Write-Host "Creating folders for Jenkins..."

New-Item -ItemType Directory -Path C:\J -ErrorAction Stop | Out-Null
New-Item -ItemType Directory -Path C:\W -ErrorAction Stop | Out-Null

Write-Host "Adding Windows Defender exclusion rule for Jenkins-related folders..."

Add-WindowsDefenderExclusionRule -Folder C:\J -ErrorAction Stop
Add-WindowsDefenderExclusionRule -Folder C:\W -ErrorAction Stop

Write-Host "Done."
