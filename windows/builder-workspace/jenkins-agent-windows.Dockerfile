# escape=`

FROM jenkins/inbound-agent:windowsservercore-ltsc2019

# Include all installation scripts
COPY Container\*.ps1 C:\Workspace\

RUN "powershell try { C:\Workspace\InstallSoftware.ps1 } catch { Write-Error $_ }"

RUN "powershell Remove-Item C:\Workspace -Recurse -Force"

ENTRYPOINT ["powershell.exe"]
