class DirectXRedistributableInstallerException : Exception {
	$ExitCode

	DirectXRedistributableInstallerException([int] $exitCode) : base("dxwebsetup.exe exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Install-DirectXRedistributable {

	$ToolsAndVersions = Import-PowerShellDataFile -Path "${PSScriptRoot}\ToolsAndVersions.psd1"

	$TempFolder = "C:\Temp"
	$RedistExeName = "dxwebsetup.exe"

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
	
	try {
	
		# Determine installer download location
		$InstallerLocation = (Join-Path -Path $TempFolder -ChildPath $RedistExeName -ErrorAction Stop)

		# Download DirectX End-User Runtime Web Installer
		Invoke-WebRequest -UseBasicParsing -Uri $ToolsAndVersions.DirectXRedistributableInstallerUrl -OutFile $InstallerLocation -ErrorAction Stop
	
		$Process = Start-Process -FilePath $InstallerLocation -ArgumentList "/q" -NoNewWindow -Wait -PassThru
	
		if ($Process.ExitCode -ne 0) {
			throw [DirectXRedistributableInstallerException]::new($Process.ExitCode)
		}

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}

