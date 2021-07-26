. ${PSScriptRoot}\..\Tools\Scripts\Register-AutoStartService.ps1

Write-Host "Registering Jenkins Agent script as autostarting..."

Register-AutoStartService -NssmLocation ${PSScriptRoot}\..\..\Runtime\Tools\nssm.exe -ServiceName "JenkinsAgent" -Program "powershell" -ArgumentList (Resolve-Path ${PSScriptRoot}\..\..\Runtime\Scripts\GCEService-Sshd.ps1)

Write-Host "Done."
