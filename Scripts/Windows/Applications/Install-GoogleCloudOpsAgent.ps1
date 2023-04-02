function Install-GoogleCloudOpsAgent {

	$ToolsAndVersions = Import-PowerShellDataFile -Path "${PSScriptRoot}\ToolsAndVersions.psd1" -ErrorAction Stop

	$TempFolder = "C:\Temp"
	$InstallScriptName = "add-google-cloud-ops-agent-repo.ps1"

	# Create temp folder
	New-Item $TempFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
	
	try {
	
		# Determine installation script download location
		$InstallScriptLocation = (Join-Path -Path $TempFolder -ChildPath $InstallScriptName -ErrorAction Stop)

		# Download installation script
		Invoke-WebRequest -UseBasicParsing -Uri $ToolsAndVersions.GoogleCloudOpsAgentInstallScriptUrl -OutFile $InstallScriptLocation -ErrorAction Stop

		# Run installation script
		Invoke-Expression "${InstallScriptLocation} -AlsoInstall" -ErrorAction Stop

	} finally {

		# Remove temp folder
		Remove-Item -Recurse $TempFolder -Force -ErrorAction Ignore
	}
}
