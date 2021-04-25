. ${PSScriptRoot}\Invoke-External.ps1

class DirectXRedistributableInstallerException : Exception {
	$ExitCode

	DirectXRedistributableInstallerException([int] $exitCode) : base("dxwebsetup.exe exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Install-DirectXRedistributable {

	$TempFolder = "C:\Temp"
	$RedistExeName = "dxwebsetup.exe"

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
	
	try {
	
		# Determine installer download location
		$InstallerLocation = (Join-Path -Path $TempFolder -ChildPath $RedistExeName -ErrorAction Stop)

		# Download DirectX End-User Runtime Web Installer
		Invoke-WebRequest -UseBasicParsing -Uri "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe" -OutFile $InstallerLocation -ErrorAction Stop
	
		$ExitCode = Invoke-External -LiteralPath $InstallerLocation "/q"
	
		if ($ExitCode -ne 0) {
			throw [DirectXRedistributableInstallerException]::new($ExitCode)
		}

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}

