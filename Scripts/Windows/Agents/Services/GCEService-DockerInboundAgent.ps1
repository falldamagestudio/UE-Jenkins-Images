# Log all output to file (in addition to console output, when run manually )
# This enables post-mortem inspection of the script's activities via log files
# It also allows GCE's logging agent to pick up the activity and forward it to Google's Cloud Logging
Start-Transcript -LiteralPath "C:\Logs\GCEService-DockerInboundAgent-$(Get-Date -Format "yyyyMMdd-HHmmss" -ErrorAction Stop).txt" -ErrorAction Stop

try {

    . ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESettings.ps1
    . ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCEInstanceHostname.ps1
    . ${PSScriptRoot}\..\..\Applications\Deploy-PlasticClientConfig.ps1
    . ${PSScriptRoot}\..\..\Applications\Authenticate-DockerForGoogleArtifactRegistry.ps1
    . ${PSScriptRoot}\..\Run\Run-DockerInboundAgent.ps1

    $DefaultFolders = Import-PowerShellDataFile -Path "${PSScriptRoot}\..\..\BuildSteps\DefaultBuildStepSettings.psd1" -ErrorAction Stop

    $AgentName = (Get-GCEInstanceHostname).Split(".")[0]

    Write-Host "Waiting for required settings to be available in Secrets Manager / Instance Metadata..."

    $RequiredSettingsSpec = @{
        JenkinsURL = @{ Name = "jenkins-url"; Source = [GCESettingSource]::Secret }
        AgentKey = @{ Name = "agent-key-file"; Source = [GCESettingSource]::Secret }
        AgentImageURL = @{ Name = "inbound-agent-image-url-windows"; Source = [GCESettingSource]::Secret }
        JenkinsSecret = @{ Name = "inbound-agent-secret-${AgentName}"; Source = [GCESettingSource]::Secret }
    }

    $RequiredSettings = Get-GCESettings $RequiredSettingsSpec -Wait -PrintProgress

    Write-Host "Fetching optional settings from Secrets Manager / Instance Metadata..."

    $OptionalSettingsSpec = @{
        PlasticConfigZip = @{ Name = "plastic-config-zip"; Source = [GCESettingSource]::Secret; Binary = $true }
    }

    $OptionalSettings = Get-GCESettings $OptionalSettingsSpec -PrintProgress

    if ($OptionalSettings.PlasticConfigZip) {
        Write-Host "Deploying Plastic SCM client configuration..."

        Deploy-PlasticClientConfig -ZipContent $OptionalSettings.PlasticConfigZip -ConfigFolder $DefaultFolders.PlasticConfigFolder
    }

    # Extract region from docker image URL
    # Example: europe-west1-docker.pkg.dev/<projectname>/<reponame>/<imagename>:<tag> => europe-west1
    $Region = ($RequiredSettings.AgentImageURL -Split "-docker.pkg.dev")[0]

    Write-Host "Authenticating Docker for Google Artifact Registry..."

    Authenticate-DockerForGoogleArtifactRegistry -AgentKey $RequiredSettings.AgentKey -Region $Region

    Write-Host "Running Jenkins Agent..."

    $ServiceParams = @{
        JenkinsAgentFolder = $DefaultFolders.JenkinsAgentFolder
        JenkinsWorkspaceFolder = $DefaultFolders.JenkinsWorkspaceFolder
        PlasticConfigFolder = $DefaultFolders.PlasticConfigFolder
        JenkinsURL = $RequiredSettings.JenkinsURL
        JenkinsSecret = $RequiredSettings.JenkinsSecret
        AgentImageURL = $RequiredSettings.AgentImageURL
        AgentName = $AgentName
    }

    Run-DockerInboundAgent @ServiceParams

    Write-Host "Done."

} finally {

    Stop-Transcript

}