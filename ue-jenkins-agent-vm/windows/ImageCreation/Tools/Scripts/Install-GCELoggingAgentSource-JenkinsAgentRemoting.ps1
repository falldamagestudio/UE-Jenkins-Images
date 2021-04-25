function Install-GCELoggingAgentSource-JenkinsAgentRemoting {

	<#
		.SYNOPSIS
		Configures the GCE Logging Agent to capture logs from the Jenkins Agent remoting
	#>

	param (
		[Parameter(Mandatory)] [string] $JenkinsAgentFolder
	)

	$JenkinsAgentFolderWithForwardSlashes = $JenkinsAgentFolder -Replace "\\","/"

	$ConfTemplateFileLocation = "${PSScriptRoot}\JenkinsAgentRemoting.conf.template"

	# Determine GCE Logging Agent installation folder based on where its uninstaller executable is located
	# This will normally result in a path like C:\Program Files (x86)\Stackdriver\LoggingAgent
	$GCELoggingAgentInstallationFolder = (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\GoogleStackdriverLoggingAgent -Name UninstallString -ErrorAction Stop).UninstallString | Split-Path -ErrorAction Stop

	$ConfFile = (Get-Content $ConfTemplateFileLocation -ErrorAction Stop) -Replace "\[JENKINS_AGENT_FOLDER_WITH_FORWARD_SLASHES\]",$JenkinsAgentFolderWithForwardSlashes -Replace "\[STACKDRIVER_LOGGING_AGENT_INSTALL_FOLDER\]",$GCELoggingAgentInstallationFolder

	$ConfFileLocation = "${GCELoggingAgentInstallationFolder}\config.d\JenkinsAgentRemoting.conf"

	$ConfFile | Out-File -FilePath $ConfFileLocation -Encoding ASCII -ErrorAction Stop
}
