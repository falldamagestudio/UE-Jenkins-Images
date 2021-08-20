class DirectXRedistributableArchiveException : Exception {
	$ExitCode

	DirectXRedistributableArchiveException([int] $exitCode) : base("Archive-package exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

class DirectXRedistributableInstallerException : Exception {
	$ExitCode

	DirectXRedistributableInstallerException([int] $exitCode) : base("dxsetup.exe exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Install-DirectXRedistributable {

	$ToolsAndVersions = Import-PowerShellDataFile -Path "${PSScriptRoot}\ToolsAndVersions.psd1"

	$TempFolder = "C:\Temp"
	$ArchiveExeName = "dxarchive.exe"
	$SetupExeName = "dxsetup.exe"

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
	
	try {
	
		# Determine archive download location
		$ArchiveLocation = (Join-Path -Path $TempFolder -ChildPath $ArchiveExeName -ErrorAction Stop)

		# Download DirectX End-User Installer (archive)
		Invoke-WebRequest -UseBasicParsing -Uri $ToolsAndVersions.DirectXRedistributableInstallerUrl -OutFile $ArchiveLocation -ErrorAction Stop

		# Unpack archive
		$Process = Start-Process -FilePath $ArchiveLocation -ArgumentList @("/q","/t:${TempFolder}") -NoNewWindow -Wait -PassThru

		if ($Process.ExitCode -ne 0) {
			throw [DirectXRedistributableArchiveException]::new($Process.ExitCode)
		}

		$InstallerLocation = (Join-Path -Path $TempFolder -ChildPath $SetupExeName -ErrorAction Stop)

		# Run installer
		$Process = Start-Process -FilePath $InstallerLocation -ArgumentList @("/silent") -NoNewWindow -Wait -PassThru
	
		if ($Process.ExitCode -ne 0) {
			throw [DirectXRedistributableInstallerException]::new($Process.ExitCode)
		}

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}
