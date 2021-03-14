class PlasticInstallerException : Exception {
	$ExitCode

	PlasticInstallerException([int] $exitCode) : base("Plastic SCM installer exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Install-Plastic {

	$TempFolder = "C:\Temp"
	$InstallerExeName = "plasticinstaller.exe"

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
	
	try {
	
		# Determine installer download location
		$InstallerLocation = (Join-Path -Path $TempFolder -ChildPath $InstallerExeName -ErrorAction Stop)

		# Download Plastic SCM Client Installer
		Invoke-WebRequest -UseBasicParsing -Uri "https://www.plasticscm.com/download/9.0.16.5201/plasticscm/windows/client" -OutFile $InstallerLocation -ErrorAction Stop
	
		$Process = Start-Process -FilePath $InstallerLocation -ArgumentList "--mode","unattended" -NoNewWindow -Wait -PassThru
	
		if ($Process.ExitCode -ne 0) {
			throw [PlasticInstallerException]::new($Process.ExitCode)
		}

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}
