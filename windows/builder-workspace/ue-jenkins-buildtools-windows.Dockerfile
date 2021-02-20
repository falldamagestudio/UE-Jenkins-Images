# escape=`

FROM mcr.microsoft.com/dotnet/framework/runtime:3.5

# Include all installation scripts
COPY Container\*.ps1 C:\Workspace\

# Include XINPUT1_3.DLL
COPY Container\*.dll C:\Workspace\

RUN "powershell try { & C:\Workspace\InstallSoftware.ps1 } catch { Write-Error $_ }"

RUN "powershell Remove-Item C:\Workspace -Recurse -Force"

ENTRYPOINT ["powershell.exe"]
