class PlasticInstallerException : Exception {
	$ExitCode

	PlasticInstallerException([int] $exitCode) : base("Plastic SCM installer exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

class PlasticConfigureServerException : Exception {
	$ExitCode

	PlasticConfigureServerException([int] $exitCode) : base("Plastic server configuration exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Install-Plastic {

	$TempFolder = "C:\Temp"
	$InstallerExeName = "plasticinstaller.exe"

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
	
	try {
	
		# Determine installer download location
		$InstallerLocation = (Join-Path -Path $TempFolder -ChildPath $InstallerExeName -ErrorAction Stop)

		# Download Plastic SCM Cloud Installer
		Invoke-WebRequest -UseBasicParsing -Uri "https://www.plasticscm.com/download/downloadinstaller/9.0.16.5201/plasticscm/windows/cloudedition" -OutFile $InstallerLocation -ErrorAction Stop

		# Run installer
		$Process = Start-Process -FilePath $InstallerLocation -ArgumentList "--mode","unattended" -NoNewWindow -Wait -PassThru
	
		if ($Process.ExitCode -ne 0) {
			throw [PlasticInstallerException]::new($Process.ExitCode)
		}

		# Configure server
		$Process2 = Start-Process -FilePath "C:\Program Files\PlasticSCM5\server\plasticd.exe" -ArgumentList "configure","--language=en","--workingmode=NameWorkingMode","--port=8084" -NoNewWindow -Wait -PassThru

		if ($Process2.ExitCode -ne 0) {
			throw [PlasticConfigureServerException]::new($Process2.ExitCode)
		}

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}
