. ${PSScriptRoot}\Invoke-External.ps1

class VSBuildToolsInstallerException : Exception {
	$ExitCode

	VSBuildToolsInstallerException([int] $exitCode) : base("vs_buildtools.exe exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Install-VisualStudioBuildTools {

	$TempFolder = "C:\Temp"
	$BuildToolsExeName = "vs_buildtools.exe"
	$InstalledFolder = "C:\BuildTools"

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null

	try {

		# Determine installer download location
		$InstallerLocation = (Join-Path -Path $TempFolder -ChildPath $BuildToolsExeName -ErrorAction Stop)

		# Download installer
		Invoke-WebRequest -UseBasicParsing -Uri "https://aka.ms/vs/16/release/vs_buildtools.exe" -OutFile $InstallerLocation -ErrorAction Stop

		# Invoke installer
		$WorkloadsAndComponents = @(
			"Microsoft.VisualStudio.Workload.VCTools"
			"Microsoft.VisualStudio.Component.VC.Tools.x86.x64"
			"Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools"	# Required to get PDBCOPY.EXE, which in turn is applied to all PDB files
			"Microsoft.VisualStudio.Component.Windows10SDK.18362"
			"Microsoft.Net.Component.4.6.2.TargetingPack"	# Required when building AutomationTool
			"Microsoft.Net.Component.4.5.TargetingPack"	# Required when building SwarmCoordinator
		)

		$Args = @("--quiet", "--wait", "--norestart", "--nocache", "--installpath", $InstalledFolder)
		
		foreach ($WorkloadOrComponent in $WorkloadsAndComponents) {
			$Args += "--add"
			$Args += $WorkloadOrComponent
		}

		$ExitCode = Invoke-External -LiteralPath $InstallerLocation @$Args

		# Particular exit codes are successful:
		# 0    == Operation completed successfully
		# 3010 == Operation completed successfully, but install requires reboot before it can be used
		# All other exit codes should result in an exception
		if (($ExitCode -ne 0) -and ($ExitCode -ne 3010)) {
			throw [VSBuildToolsInstallerException]::new($ExitCode)
		}

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}
