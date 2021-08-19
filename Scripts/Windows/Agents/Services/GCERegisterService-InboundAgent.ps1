. ${PSScriptRoot}\..\..\SystemConfiguration\Register-AutoStartService.ps1

function GCERegisterService-InboundAgent {
    Register-AutoStartService -ServiceName "JenkinsAgent" -Program "powershell" -ArgumentList (Resolve-Path ${PSScriptRoot}\GCEService-InboundAgent.ps1)
}
