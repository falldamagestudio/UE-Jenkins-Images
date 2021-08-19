. ${PSScriptRoot}\..\..\SystemConfiguration\Register-AutoStartService.ps1

function GCERegisterService-SshAgent-Startup {
    Register-AutoStartService -ServiceName "JenkinsAgent" -Program "powershell" -ArgumentList (Resolve-Path ${PSScriptRoot}\GCEService-SshAgent-Startup.ps1)
}
