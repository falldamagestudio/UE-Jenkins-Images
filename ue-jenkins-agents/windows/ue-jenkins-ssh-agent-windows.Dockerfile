# escape=`

FROM jenkins/agent:4.7-1-jdk11-windowsservercore-ltsc2019@sha256:ab08be256ad3f63839ed76eee4f6040f6227f1606d568200c9877f96ff7677d5

# Include shared installation scripts
COPY Scripts\Windows\* C:\Workspace\

# Include specific installation scripts
COPY ue-jenkins-agents\windows\Container\* C:\Workspace\

RUN try { C:\Workspace\InstallSoftware.ps1 } catch { Write-Error $_ } `
    Remove-Item C:\Workspace -Recurse -Force
