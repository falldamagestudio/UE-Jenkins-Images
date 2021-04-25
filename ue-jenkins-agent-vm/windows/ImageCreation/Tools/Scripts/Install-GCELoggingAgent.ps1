function Install-GCELoggingAgent {

	<#
		.SYNOPSIS
		Downloads and installs the GCE Logging Agent.
	#>

	$TempFolder = "C:\Temp"
	$LoggingAgentDownloadURI = "https://dl.google.com/cloudagents/windows/StackdriverLogging-v1-15.exe"

	$LoggingAgentInstallerExeName = "LoggingAgent.exe"

	New-Item $TempFolder -ItemType Directory -ErrorAction Stop | Out-Null

	try {

		$InstallerLocation = (Join-Path -Path $TempFolder -ChildPath $LoggingAgentInstallerExeName)

		# This downloads and installs a fixed version of the logging agent.
		# Reference: https://cloud.google.com/logging/docs/agent/installation#installing_a_specific_version_of_the_agent
		# There is also an "install latest-available version" flow.
		# It might also be possible to handle installation & upgrades via Agent Policies in the future.

		Invoke-WebRequest -UseBasicParsing -Uri $LoggingAgentDownloadURI -OutFile $InstallerLocation -ErrorAction Stop

		$Process = Start-Process -FilePath $InstallerLocation -ArgumentList "/S" -NoNewWindow -Wait -PassThru -ErrorAction Stop

		# Installation is asynchronous; the agent has not yet completed installation when the installer exits.

		if ($Process.ExitCode -ne 0) {
			throw
		}

	} finally {

		Remove-Item -Recurse $TempFolder -ErrorAction SilentlyContinue

	}
}
