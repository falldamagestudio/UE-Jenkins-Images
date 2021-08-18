. ${PSScriptRoot}\..\..\SystemConfiguration\Register-AutoStartService.ps1

function GCERegisterService-InboundAgent {
    Register-AutoStartService -NssmLocation ${PSScriptRoot}\..\..\SystemConfiguration\nssm.exe -ServiceName "JenkinsAgent" -Program "powershell" -ArgumentList (Resolve-Path ${PSScriptRoot}\GCEService-InboundAgent.ps1)
}
