# escape=`

FROM mcr.microsoft.com/dotnet/framework/runtime:3.5

# User name should not be 'Jenkins', because...
# - The jenkins agent container is built with a user named 'Jenkins'
# - that container has volumes at c:\Users\Jenkins\<subdir> declared in the Jenkinsfile
# - When the Docker Pipeline plugin launches the build tools container,
#    it will launch it with a commandline like 'docker run ... --volumes-from=<agent container> <buildtools container>'
# - The --volumes-from operation will mirror the volumes and their automatic mount points
#    into the build tools container
# - This results in a conflict for the C:\Users\Jenkins directory
# - Windows' container driver will remap the build tools' user folder
#    to C:\Users\Jenkins.<MACHINENAME> instead
# - This means that in the build tools container, C:\Users\Jenkins will only contain
#    whatever mounts exist in the agent container, and the 'real' home folder
#    will be located at ${env:USERPROFILE} = C:\Users\Jenkins.<MACHINENAME>
# - To avoid this confusion, we should make sure to not use 'Jenkins' as user name for
#    this container
#
# One side effect of the above is that it is not possible to bind-mount a host directory
#  into a subfolder under the user's home directory across all containers
# The compatible way to accomplish it is to bind-mount the host directory to C:\<global location>
#  and then have a symlink in each image that points from home-subfolder to c:\<global location>

ARG user=JenkinsBuildTools

# Install scripts expect shell to be Powershell
SHELL [ "powershell", "-Command" ]

RUN net user "${env:user}" /add /expire:never /passwordreq:no ; `
    net localgroup Administrators /add $env:user ; `
    Set-LocalUser -Name $env:user -PasswordNeverExpires 1
	
USER $user

COPY Scripts C:\Scripts

COPY Docker C:\Docker

RUN try { `
        & C:\Docker\ue-jenkins-buildtools\windows\ContainerBuild.ps1 `
    } catch { `
        Write-Error $_; throw $_ `
    } finally { `
        Remove-Item -Recurse -Force -Path C:\Docker -ErrorAction SilentlyContinue `
    }

# Jenkins expects shell to be cmd
SHELL ["cmd", "/S", "/C" ]

CMD ["cmd.exe"]
