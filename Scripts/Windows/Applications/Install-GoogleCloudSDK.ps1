class GoogleCloudSDKInstallerException : Exception {
	$ExitCode

	GoogleCloudSDKInstallerException([int] $exitCode) : base("Google Cloud SDK installer exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Install-GoogleCloudSDK {

	$ToolsAndVersions = Import-PowerShellDataFile -Path "${PSScriptRoot}\ToolsAndVersions.psd1" -ErrorAction Stop

	$TempFolder = "C:\Temp"
	$ArchiveName = "google-cloud-sdk.zip"
	$InstallFolder = "C:\Program Files" # The Google Cloud SDK will install into a folder named 'google-cloud-sdk' within thie folder
	$BinFolder = "google-cloud-sdk\bin" # Location of binaries folder within Google Cloud SDK package

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
	try {
	
		# Determine archive download location
		$ArchiveLocation = (Join-Path -Path $TempFolder -ChildPath $ArchiveName -ErrorAction Stop)

		# Download Google Cloud SDK package
		Invoke-WebRequest -UseBasicParsing -Uri $ToolsAndVersions.GoogleCloudSDKInstallerUrl -OutFile $ArchiveLocation -ErrorAction Stop

        # Unpack SDK to installation folder
		# Note that the Google Cloud SDK is placed within a folder called 'google-cloud-sdk' within the archive,
		#  so we will not create a folder for the SDK within Program Files ourselves
        Expand-Archive -Path $ArchiveLocation -DestinationPath $InstallFolder

		# Add Google Cloud SDK bin folder to all users' PATH
		$BinLocation = (Join-Path -Path $InstallFolder -ChildPath $BinFolder)
		$AllUsersEnvironmentPath = 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
		$CurrentPath = (Get-ItemProperty -Path $AllUsersEnvironmentPath).Path
		$NewPath = "${CurrentPath};${BinLocation}"
		Set-ItemProperty -Path $AllUsersEnvironmentPath -Name "Path" -Value $NewPath

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}
