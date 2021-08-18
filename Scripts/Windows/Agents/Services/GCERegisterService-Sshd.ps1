. ${PSScriptRoot}\..\..\SystemConfiguration\Register-AutoStartService.ps1

Write-Host "Registering Jenkins Agent script as autostarting..."

Register-AutoStartService -NssmLocation ${PSScriptRoot}\..\..SystemConfiguration\nssm.exe -ServiceName "JenkinsAgent" -Program "powershell" -ArgumentList (Resolve-Path ${PSScriptRoot}\GCEService-Sshd.ps1)

Write-Host "Done."
