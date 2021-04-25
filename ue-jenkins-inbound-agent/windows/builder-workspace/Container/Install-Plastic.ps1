. ${PSScriptRoot}\Invoke-External.ps1

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
		$ExitCode = Invoke-External -LiteralPath $InstallerLocation "--mode" "unattended"
	
		if ($ExitCode -ne 0) {
			throw [PlasticInstallerException]::new($ExitCode)
		}

		# Configure server
		$ExitCode2 = Invoke-External -LiteralPath "C:\Program Files\PlasticSCM5\server\plasticd.exe" "configure" "--language=en" "--workingmode=NameWorkingMode" "--port=8084"

		if ($ExitCode2 -ne 0) {
			throw [PlasticConfigureServerException]::new($ExitCode2)
		}

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}
