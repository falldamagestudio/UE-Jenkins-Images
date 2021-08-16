function Install-GCELoggingAgentSource-ServiceWrapper {

	<#
		.SYNOPSIS
		Configures the GCE Logging Agent to capture logs from the service wrapper
	#>

	param (
		[Parameter(Mandatory)] [string] $ServiceWrapperLogsFolder
	)

	$ServiceWrapperLogsFolderWithForwardSlashes = $ServiceWrapperLogsFolder -Replace "\\","/"

	$ConfTemplateFileLocation = "${PSScriptRoot}\ServiceWrapper.conf.template"

	# Determine GCE Logging Agent installation folder based on where its uninstaller executable is located
	# This will normally result in a path like C:\Program Files (x86)\Stackdriver\LoggingAgent
	$GCELoggingAgentInstallationFolder = (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\GoogleStackdriverLoggingAgent -Name UninstallString -ErrorAction Stop).UninstallString | Split-Path -ErrorAction Stop

	$ConfFile = (Get-Content $ConfTemplateFileLocation -ErrorAction Stop) -Replace "\[SERVICE_WRAPPER_LOGS_FOLDER_WITH_FORWARD_SLASHES\]",$ServiceWrapperLogsFolderWithForwardSlashes -Replace "\[STACKDRIVER_LOGGING_AGENT_INSTALL_FOLDER\]",$GCELoggingAgentInstallationFolder

	$ConfFileLocation = "${GCELoggingAgentInstallationFolder}\config.d\ServiceWrapper.conf"

	$ConfFile | Out-File -FilePath $ConfFileLocation -Encoding ASCII -ErrorAction Stop
}
