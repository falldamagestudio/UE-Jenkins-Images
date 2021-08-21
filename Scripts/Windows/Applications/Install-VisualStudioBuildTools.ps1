class VSBuildToolsInstallerException : Exception {
	$ExitCode

	VSBuildToolsInstallerException([int] $exitCode) : base("vs_buildtools.exe exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Install-VisualStudioBuildTools {

	$ToolsAndVersions = Import-PowerShellDataFile -Path "${PSScriptRoot}\ToolsAndVersions.psd1" -ErrorAction Stop

	$TempFolder = "C:\Temp"
	$BuildToolsExeName = "vs_buildtools.exe"
	$InstalledFolder = "C:\BuildTools"

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null

	try {

		# Determine installer download location
		$InstallerLocation = (Join-Path -Path $TempFolder -ChildPath $BuildToolsExeName -ErrorAction Stop)

		# Download installer
		Invoke-WebRequest -UseBasicParsing -Uri $ToolsAndVersions.VisualStudioBuildTools.InstallerUrl -OutFile $InstallerLocation -ErrorAction Stop

		# Invoke installer

		$Args = @("--quiet", "--wait", "--norestart", "--nocache", "--installpath", $InstalledFolder)
		
		foreach ($WorkloadOrComponent in $ToolsAndVersions.VisualStudioBuildTools.WorkloadsAndComponents) {
			$Args += "--add"
			$Args += $WorkloadOrComponent
		}

		$Process = Start-Process -FilePath $InstallerLocation -ArgumentList $Args -NoNewWindow -Wait -PassThru

		# Particular exit codes are successful:
		# 0    == Operation completed successfully
		# 3010 == Operation completed successfully, but install requires reboot before it can be used
		# All other exit codes should result in an exception
		if (($Process.ExitCode -ne 0) -and ($Process.ExitCode -ne 3010)) {
			throw [VSBuildToolsInstallerException]::new($Process.ExitCode)
		}

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}
