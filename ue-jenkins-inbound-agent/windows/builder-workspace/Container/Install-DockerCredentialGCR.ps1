class DockerCredentialGCRInstallerException : Exception {
	$ExitCode

	DockerCredentialGCRInstallerException([int] $exitCode) : base("docker-credential-gcr installer exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

class DockerCredentialGCRConfigureServerException : Exception {
	$ExitCode

	DockerCredentialGCRConfigureServerException([int] $exitCode) : base("DockerCredentialGCR server configuration exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Install-DockerCredentialGCR {

	$TempFolder = "C:\Temp"
	$ArchiveName = "docker-credential-gcr.tgz"
    $ProgramFolder = "C:\Program Files\docker-credential-gcr"

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
	try {
	
		# Determine archive download location
		$ArchiveLocation = (Join-Path -Path $TempFolder -ChildPath $ArchiveName -ErrorAction Stop)

		# Download docker-credential-gcr package
		Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v2.0.4/docker-credential-gcr_windows_amd64-2.0.4.tar.gz" -OutFile $ArchiveLocation -ErrorAction Stop

        # Create docker-credential-gcr folder
    	New-Item $ProgramFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null

        # Unpack application to program folder
        tar -xvf $ArchiveLocation -C $ProgramFolder | Out-Null

        # Add docker-credential-gcr folder to all users' PATH
        $AllUsersEnvironmentPath = 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
        $CurrentPath = (Get-ItemProperty -Path $AllUsersEnvironmentPath).Path
        $NewPath = "${CurrentPath};${ProgramFolder}"
        Set-ItemProperty -Path $AllUsersEnvironmentPath -Name "Path" -Value $NewPath

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}
