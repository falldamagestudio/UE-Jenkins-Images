class AdoptiumOpenJDKInstallerException : Exception {
	$ExitCode

	AdoptiumOpenJDKInstallerException([int] $exitCode) : base("msiexec installer run for AdoptiumOpenJDK exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Install-AdoptiumOpenJDK {

	$ToolsAndVersions = Import-PowerShellDataFile -Path "${PSScriptRoot}\ToolsAndVersions.psd1"

	$TempFolder = "C:\Temp"
	$InstallerName = "AdoptiumOpenJdk.msi"

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
	
	try {
	
		# Determine installer download location
		$InstallerLocation = (Join-Path -Path $TempFolder -ChildPath $InstallerName -ErrorAction Stop)

		# Download Adoptium JDK MSI
		Invoke-WebRequest -UseBasicParsing -Uri $ToolsAndVersions.AdoptiumOpenJDKInstallerUrl -OutFile $InstallerLocation -ErrorAction Stop
	
		$Process = Start-Process -FilePath "msiexec" -ArgumentList @("/I", $InstallerLocation, "INSTALLLEVEL=1", "/quiet") -NoNewWindow -Wait -PassThru
	
		if ($Process.ExitCode -ne 0) {
			throw [AdoptiumOpenJDKInstallerException]::new($Process.ExitCode)
		}

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}
