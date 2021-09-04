. ${PSScriptRoot}\..\Applications\Install-GCELoggingAgent.ps1
. ${PSScriptRoot}\..\Applications\Install-GCELoggingAgentSource-ServiceWrapper.ps1
. ${PSScriptRoot}\..\Applications\Install-GCELoggingAgentSource-JenkinsAgentRemoting.ps1

function BuildStep-InstallGCELoggingAgent {

    $VMSettings = Import-PowerShellDataFile "${PSScriptRoot}\..\VMSettings.psd1"

    Write-Host "Installing GCE Logging Agent..."

    # This will provide the basic forwarding of logs to GCP Logging, and send various Windows Event log activity there
    Install-GCELoggingAgent
    
    Write-Host "Installing forwarding of service wrapper logs to GCP Logging..."
    
    Install-GCELoggingAgentSource-ServiceWrapper -ServiceWrapperLogsFolder $VMSettings.ServiceWrapperLogsFolder
    
    Write-Host "Installing forwarding of Jenkins Agent remoting logs to GCP Logging..."
    
    Install-GCELoggingAgentSource-JenkinsAgentRemoting -JenkinsAgentFolder $VMSettings.JenkinsAgentFolder
}