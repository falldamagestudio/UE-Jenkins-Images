class GoogleCloudSDKInstallerException : Exception {
	$ExitCode

	GoogleCloudSDKInstallerException([int] $exitCode) : base("Google Cloud SDK installer exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Install-GoogleCloudSDK {

	$TempFolder = "C:\Temp"
	$ArchiveName = "google-cloud-sdk.zip"
	$ProgramFilesFolder = "C:\Program Files"
    $ProgramFolder = "C:\Program Files\google-cloud-sdk"

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
	try {
	
		# Determine archive download location
		$ArchiveLocation = (Join-Path -Path $TempFolder -ChildPath $ArchiveName -ErrorAction Stop)

		# Download Google Cloud SDK package
		Invoke-WebRequest -UseBasicParsing -Uri "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-336.0.0-windows-x86_64-bundled-python.zip" -OutFile $ArchiveLocation -ErrorAction Stop

        # Unpack SDK to installation folder
		# Note that the Google Cloud SDK is placed within a folder called 'google-cloud-sdk' within the archive,
		#  so we will not create a folder for the SDK within Program Files ourselves
        Expand-Archive -Path $ArchiveLocation -DestinationPath $ProgramFilesFolder

		# Run installation script
		$InstallBatLocation = (Join-Path -Path ${ProgramFolder} -ChildPath "install.bat")
		$Process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c","""${InstallBatLocation}""","--usage-reporting","false","--path-update","true","--quiet" -Wait -NoNewWindow -PassThru

		if ($Process.ExitCode -ne 0) {
			throw [GoogleCloudSDKInstallerException]::new($Process.ExitCode)
		}

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}
