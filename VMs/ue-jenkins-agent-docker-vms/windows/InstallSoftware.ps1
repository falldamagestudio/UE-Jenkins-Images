. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\SystemConfiguration\Enable-Win32LongPaths.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\SystemConfiguration\Add-WindowsDefenderExclusionRule.ps1

. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Applications\Install-GCELoggingAgent.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Applications\Install-GCELoggingAgentSource-ServiceWrapper.ps1
. ${PSScriptRoot}\..\..\..\..\Scripts\Windows\Applications\Install-GCELoggingAgentSource-JenkinsAgentRemoting.ps1

$ServiceWrapperLogsFolder = "C:\Logs"
$JenkinsAgentFolder = "C:\J"
$JenkinsWorkspaceFolder = "C:\W"

$PlasticConfigFolder = "C:\PlasticConfig"

Write-Host "Enabling Win32 Long Paths..."

Enable-Win32LongPaths

Write-Host "Creating folders for logs..."

New-Item -ItemType Directory -Path $ServiceWrapperLogsFolder -ErrorAction Stop | Out-Null

Write-Host "Creating folders for Jenkins..."

New-Item -ItemType Directory -Path $JenkinsAgentFolder -ErrorAction Stop | Out-Null
New-Item -ItemType Directory -Path $JenkinsWorkspaceFolder -ErrorAction Stop | Out-Null

Write-Host "Creating config folder for Plastic SCM..."

New-Item -ItemType Directory -Path $PlasticConfigFolder -ErrorAction Stop | Out-Null

Write-Host "Adding Windows Defender exclusion rule for Jenkins-related folders..."

Add-WindowsDefenderExclusionRule -Folder $JenkinsAgentFolder -ErrorAction Stop
Add-WindowsDefenderExclusionRule -Folder $JenkinsWorkspaceFolder -ErrorAction Stop

Write-Host "Installing GCE Logging Agent..."

# This will provide the basic forwarding of logs to GCP Logging, and send various Windows Event log activity there
Install-GCELoggingAgent

Write-Host "Installing forwarding of service wrapper logs to GCP Logging..."

Install-GCELoggingAgentSource-ServiceWrapper -ServiceWrapperLogsFolder $ServiceWrapperLogsFolder

Write-Host "Installing forwarding of Jenkins Agent remoting logs to GCP Logging..."

Install-GCELoggingAgentSource-JenkinsAgentRemoting -JenkinsAgentFolder $JenkinsAgentFolder

Write-Host "Done."
