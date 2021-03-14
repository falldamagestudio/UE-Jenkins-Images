# escape=`

FROM jenkins/inbound-agent:windowsservercore-ltsc2019@sha256:ca525de44ed36fe27694d91c5cfcaece9f43baefb1c9fc0e15b02722a9680bc7

# Include all installation scripts
COPY Container\*.ps1 C:\Workspace\

RUN try { write-host started; C:\Workspace\InstallSoftware.ps1 } catch { Write-Error $_ }

RUN Remove-Item C:\Workspace -Recurse -Force
