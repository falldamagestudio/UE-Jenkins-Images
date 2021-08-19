class GitInstallerException : Exception {
	$ExitCode

	GitInstallerException([int] $exitCode) : base("Git installer exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Install-Git {

	$TempFolder = "C:\Temp"
	$InstallerName = "GitInstaller.exe"

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
	
	try {
	
		# Determine installer download location
		$InstallerLocation = (Join-Path -Path $TempFolder -ChildPath $InstallerName -ErrorAction Stop)

		# Download Git for Windows Installer
		Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/git-for-windows/git/releases/download/v2.33.0.windows.1/Git-2.33.0-64-bit.exe" -OutFile $InstallerLocation -ErrorAction Stop
	
		$Process = Start-Process -FilePath $InstallerLocation -ArgumentList @("/SILENT", "/SUPPRESSMSGBOXES", "/NORESTART") -NoNewWindow -Wait -PassThru
	
		if ($Process.ExitCode -ne 0) {
			throw [GitInstallerException]::new($Process.ExitCode)
		}

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}
