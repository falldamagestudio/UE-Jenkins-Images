class DirectXRedistributableWebInstallerException : Exception {
	$ExitCode

	DirectXRedistributableWebInstallerException([int] $exitCode) : base("dxwebsetup.exe exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

# We are no longer using the web installer. It is too finicky to get working in different situations.
# It won't install within a Windows Server Core container.
# It will install within a Windows Server Desktop VM, if driven by the windows-docker-image-builder ... but not by packer (dxwebsetup exits with exit code -9).
#
# Instead, use Install-DirectXRedistributable.

function Install-DirectXRedistributableWeb {

	$ToolsAndVersions = Import-PowerShellDataFile -Path "${PSScriptRoot}\ToolsAndVersions.psd1"

	$TempFolder = "C:\Temp"
	$RedistExeName = "dxwebsetup.exe"

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
	
	try {
	
		# Determine installer download location
		$InstallerLocation = (Join-Path -Path $TempFolder -ChildPath $RedistExeName -ErrorAction Stop)

		# Download DirectX End-User Runtime Web Installer
		Invoke-WebRequest -UseBasicParsing -Uri $ToolsAndVersions.DirectXRedistributableWebInstallerUrl -OutFile $InstallerLocation -ErrorAction Stop
	
		$Process = Start-Process -FilePath $InstallerLocation -ArgumentList "/q" -NoNewWindow -Wait -PassThru
	
		if ($Process.ExitCode -ne 0) {
			throw [DirectXRedistributableWebInstallerException]::new($Process.ExitCode)
		}

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}

