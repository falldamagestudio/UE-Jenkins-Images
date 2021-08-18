# escape=`

FROM jenkins/agent:4.7-1-jdk11-windowsservercore-ltsc2019@sha256:ab08be256ad3f63839ed76eee4f6040f6227f1606d568200c9877f96ff7677d5

COPY Scripts C:\Scripts

COPY Docker C:\Docker

RUN try { `
        & C:\Docker\agents\windows\ContainerBuild.ps1 `
    } catch { `
        Write-Error $_; throw $_ `
    } finally { `
        Remove-Item -Recurse -Force -Path C:\Docker -ErrorAction SilentlyContinue `
    }
