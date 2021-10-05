# escape=`

FROM jenkins/inbound-agent:4.10-3-jdk11-windowsservercore-ltsc2019@sha256:88abb0a741b99f37e3b91aa6307d57a3d257c503a8d67ec79f788e848c0c308f

COPY Scripts C:\Scripts

COPY Docker C:\Docker

RUN try { `
        & C:\Docker\agents\windows\ContainerBuild.ps1 `
    } catch { `
        Write-Error $_; throw $_ `
    } finally { `
        Remove-Item -Recurse -Force -Path C:\Docker -ErrorAction SilentlyContinue `
    }
