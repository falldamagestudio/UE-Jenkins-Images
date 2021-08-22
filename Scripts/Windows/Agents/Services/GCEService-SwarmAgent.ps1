# Log all output to file (in addition to console output, when run manually )
# This enables post-mortem inspection of the script's activities via log files
# It also allows GCE's logging agent to pick up the activity and forward it to Google's Cloud Logging
Start-Transcript -LiteralPath "C:\Logs\GCEService-SwarmAgent-$(Get-Date -Format "yyyyMMdd-HHmmss" -ErrorAction Stop).txt" -ErrorAction Stop

try {

    . ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESettings.ps1
    . ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCEInstanceHostname.ps1
    . ${PSScriptRoot}\..\Run\Run-SwarmAgent.ps1

    $DefaultFolders = Import-PowerShellDataFile -Path "${PSScriptRoot}\..\..\BuildSteps\DefaultBuildStepSettings.psd1" -ErrorAction Stop

    $AgentName = (Get-GCEInstanceHostname).Split(".")[0]

    Write-Host "Waiting for required settings to be available in Secrets Manager / Instance Metadata..."

    $RequiredSettingsSpec = @{
        JenkinsURL = @{ Name = "jenkins-url"; Source = [GCESettingSource]::Secret }
        AgentUsername = @{ Name = "swarm-agent-username"; Source = [GCESettingSource]::Secret }
        AgentAPIToken = @{ Name = "swarm-agent-api-token"; Source = [GCESettingSource]::Secret }
        Labels = @{ Name = "jenkins-labels"; Source = [GCESettingSource]::InstanceMetadata }
    }

    $RequiredSettings = Get-GCESettings $RequiredSettingsSpec -Wait -PrintProgress

    Write-Host "Waiting for SSH Server to start..."

    (Get-Service -Name "sshd").WaitForStatus("Running")

    Write-Host "Running Jenkins Agent..."

    Write-Host $RequiredSettings

    $ServiceParams = @{
        JenkinsAgentFolder = $DefaultFolders.JenkinsAgentFolder
        JenkinsWorkspaceFolder = $DefaultFolders.JenkinsWorkspaceFolder
        JenkinsURL = $RequiredSettings.JenkinsURL
        AgentUsername = $RequiredSettings.AgentUsername
        AgentAPIToken = $RequiredSettings.AgentAPIToken
        NumExecutors = 1
        Labels = $RequiredSettings.Labels
        AgentName = $AgentName
    }

    Run-SwarmAgent @ServiceParams

    Write-Host "Done."

} finally {

    Stop-Transcript

}