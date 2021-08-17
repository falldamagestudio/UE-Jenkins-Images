# escape=`

FROM jenkins/inbound-agent:4.7-1-jdk11-windowsservercore-ltsc2019@sha256:9059353c2f70278e11d6a3ed7c258b24c299939de54885e6319f229c35cee23f

COPY Scripts C:\Scripts

COPY Docker C:\Docker

RUN try { `
        & C:\Docker\ue-jenkins-agents\windows\ContainerBuild.ps1 `
    } catch { `
        Write-Error $_; throw $_ `
    } finally { `
        Remove-Item -Recurse -Force -Path C:\Docker -ErrorAction SilentlyContinue `
    }
