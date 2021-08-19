. ${PSScriptRoot}\..\..\SystemConfiguration\Register-AutoStartService.ps1

function GCERegisterService-DockerSshAgent-Startup {
    Register-AutoStartService -ServiceName "JenkinsAgent" -Program "powershell" -ArgumentList (Resolve-Path ${PSScriptRoot}\GCEService-DockerSshAgent-Startup.ps1)
}
