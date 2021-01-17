# escape=`

FROM mcr.microsoft.com/dotnet/framework/runtime:3.5

# Include all installation scripts
COPY Container\*.ps1 C:\Workspace\

# Include XINPUT1_3.DLL
COPY Container\*.dll C:\Workspace\

RUN "powershell -File C:\Workspace\InstallSoftware.ps1"

RUN "powershell Remove-Item C:\Workspace -Recurse -Force"

ENTRYPOINT ["powershell.exe"]
