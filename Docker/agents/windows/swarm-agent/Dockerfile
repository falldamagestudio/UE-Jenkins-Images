# escape=`

FROM jenkins/openjdk:11-jdk-hotspot-windowsservercore-ltsc2019

ARG VERSION=3.28
ARG user=jenkins

ARG SWARM_CLIENT_FILENAME=swarm-client.jar

ARG AGENT_ROOT=C:/Users/${user}
ARG AGENT_WORKDIR=${AGENT_ROOT}/Work

ARG GIT_VERSION=2.31.0
ARG GIT_PATCH_VERSION=1

ARG GIT_LFS_VERSION=2.13.2

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV AGENT_WORKDIR=${AGENT_WORKDIR}

# Create Jenkins user

RUN net user "${env:user}" /add /expire:never /passwordreq:no ; `
    net localgroup Administrators /add $env:user ; `
    Set-LocalUser -Name $env:user -PasswordNeverExpires 1; `
    New-Item -ItemType Directory -Path C:/ProgramData/Jenkins | Out-Null

# Get the Swarm client from the Jenkins Artifacts Repository
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
    Invoke-WebRequest $('https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/{0}/swarm-client-{0}.jar' -f $env:VERSION) -OutFile $(Join-Path C:/ProgramData/Jenkins $env:SWARM_CLIENT_FILENAME) -UseBasicParsing ;

USER ${user}

RUN New-Item -Type Directory $('{0}/.jenkins' -f $env:AGENT_ROOT) | Out-Null ; `
    New-Item -Type Directory $env:AGENT_WORKDIR | Out-Null

VOLUME ${AGENT_ROOT}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR ${AGENT_ROOT}

# Install Git

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
    $url = $('https://github.com/git-for-windows/git/releases/download/v{0}.windows.{1}/MinGit-{0}-64-bit.zip' -f $env:GIT_VERSION, $env:GIT_PATCH_VERSION) ; `
    Write-Host "Retrieving $url..." ; `
    Invoke-WebRequest $url -OutFile 'mingit.zip' -UseBasicParsing ; `
    Expand-Archive mingit.zip -DestinationPath c:\mingit ; `
    Remove-Item mingit.zip -Force

# Install Git LFS

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
    $url = $('https://github.com/git-lfs/git-lfs/releases/download/v{0}/git-lfs-windows-amd64-v{0}.zip' -f $env:GIT_LFS_VERSION) ; `
    Write-Host "Retrieving $url..." ; `
    Invoke-WebRequest $url -OutFile 'GitLfs.zip' -UseBasicParsing ; `
    Expand-Archive GitLfs.zip -DestinationPath c:\mingit\mingw64\bin ; `
    Remove-Item GitLfs.zip -Force ; `
    & C:\mingit\cmd\git.exe lfs install ; `
    $CurrentPath = (Get-Itemproperty -path 'hklm:\system\currentcontrolset\control\session manager\environment' -Name Path).Path ; `
    $NewPath = $CurrentPath + ';C:\mingit\cmd' ; `
    Set-ItemProperty -path 'hklm:\system\currentcontrolset\control\session manager\environment' -Name Path -Value $NewPath

# Install additional software

COPY Scripts C:\Scripts

COPY Docker C:\Docker

RUN try { `
        & C:\Docker\agents\windows\ContainerBuild.ps1 `
    } catch { `
        Write-Error $_; throw $_ `
    } finally { `
        Remove-Item -Recurse -Force -Path C:\Docker -ErrorAction SilentlyContinue `
    }

# Include agent start script

COPY Docker\agents\windows\swarm-agent\swarm-agent.ps1 C:/ProgramData/Jenkins

ENTRYPOINT ["powershell.exe", "-f", "C:/ProgramData/Jenkins/swarm-agent.ps1"]
