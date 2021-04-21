. ${PSScriptRoot}\..\Tools\Scripts\Get-GCEInstanceMetadata.ps1
. ${PSScriptRoot}\..\Tools\Scripts\Get-GCESecret.ps1
. ${PSScriptRoot}\..\Tools\Scripts\Authenticate-DockerForGoogleArtifactRegistry.ps1
. ${PSScriptRoot}\..\Tools\Scripts\Run-JenkinsAgent.ps1

$JenkinsAgentFolder = "C:\J"
$JenkinsWorkspaceFolder = "C:\W"

$AgentName = $(hostname)

# Fetch configuration parameters repeatedly, until all are available
while ($true) {

    Write-Host "Retrieving configuration from instance metadata..."

    $JenkinsURL = Get-GCEInstanceMetadata -Key "jenkins-url"
    $AgentImageURL = Get-GCEInstanceMetadata -Key "agent-image-url"

    Write-Host "Retrieving configuration from Secrets Manager..."

    $AgentKey = Get-GCESecret -Key "agent-key-file"
    $JenkinsSecret = Get-GCESecret -Key "${AgentName}-secret"

    Write-Host "Instance metadata jenkins-url: $(if ($JenkinsURL -ne $null) { "found" } else { "not found" })"
    Write-Host "Instance metadata agent-image-url: $(if ($AgentImageURL -ne $null) { "found" } else { "not found" })"
    Write-Host "Secret agent-key-file: $(if ($AgentKey -ne $null) { "found" } else { "not found" })"
    Write-Host "Secret ${AgentName}-secret: $(if ($JenkinsSecret -ne $null) { "found" } else { "not found" })"

    if (($JenkinsURL -ne $null) -and ($AgentImageURL -ne $null) -and ($AgentKey -ne $null) -and ($JenkinsSecret -ne $null)) {
        break
    } else {
        Write-Host "Some parameters are missing. Sleeping, then retrying..."
        Start-Sleep 10
    }
}

# Extract region from docker image URL
# Example: europe-west1-docker.pkg.dev/<projectname>/<reponame>/<imagename>:<tag> => europe-west1
$Region = ($AgentImageURL -Split "-docker.pkg.dev")[0]

Write-Host "Authenticating Docker for Google Artifact Registry..."

Authenticate-DockerForGoogleArtifactRegistry -AgentKey $AgentKey -Region $Region

Write-Host "Running Jenkins Agent..."

$ServiceParams = @{
    JenkinsAgentFolder = $JenkinsAgentFolder
    JenkinsWorkspaceFolder = $JenkinsWorkspaceFolder
    JenkinsURL = $JenkinsURL
    JenkinsSecret = $JenkinsSecret
    AgentImageURL = $AgentImageURL
    AgentName = $AgentName
}

Run-JenkinsAgent @ServiceParams

Write-Host "Done."