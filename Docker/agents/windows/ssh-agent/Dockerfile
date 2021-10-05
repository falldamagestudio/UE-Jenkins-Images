# escape=`

FROM jenkins/agent:4.10-6-jdk11-windowsservercore-ltsc2019@sha256:2a5e0ba4cd814fca141fe87fc5576f893683101cd9309e06096c4ba9357fa7ea

COPY Scripts C:\Scripts

COPY Docker C:\Docker

RUN try { `
        & C:\Docker\agents\windows\ContainerBuild.ps1 `
    } catch { `
        Write-Error $_; throw $_ `
    } finally { `
        Remove-Item -Recurse -Force -Path C:\Docker -ErrorAction SilentlyContinue `
    }
