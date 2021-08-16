class DebuggingToolsForWindowsInstallerException : Exception {
	$ExitCode

	DebuggingToolsForWindowsInstallerException([int] $exitCode) : base("winsdksetup.exe exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Install-DebuggingToolsForWindows {

	$TempFolder = "C:\Temp"
	$BuildToolsExeName = "winsdksetup.exe"

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
	
	try {
	
		# Determine installer download location
		$InstallerLocation = (Join-Path -Path $TempFolder -ChildPath $BuildToolsExeName -ErrorAction Stop)

		# Download Windows SDK
		Invoke-WebRequest -UseBasicParsing -Uri "https://go.microsoft.com/fwlink/p/?linkid=2120843" -OutFile $InstallerLocation -ErrorAction Stop
	
		$Process = Start-Process -FilePath $InstallerLocation -ArgumentList "/norestart","/quiet","/features","OptionId.WindowsDesktopDebuggers" -NoNewWindow -Wait -PassThru
	
		if ($Process.ExitCode -ne 0) {
			throw [DebuggingToolsForWindowsInstallerException]::new($Process.ExitCode)
		}

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}
