# Log all output to file (in addition to console output, when run manually )
# This enables post-mortem inspection of the script's activities via log files
# It also allows GCE's logging agent to pick up the activity and forward it to Google's Cloud Logging
Start-Transcript -LiteralPath "C:\Logs\GCEService-SwarmAgent-$(Get-Date -Format "yyyyMMdd-HHmmss").txt"

try {

    . ${PSScriptRoot}\..\..\SystemConfiguration\Resize-PartitionToMaxSize.ps1
    . ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESecret.ps1
    . ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCEInstanceHostname.ps1
    . ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCEInstanceMetadata.ps1
    . ${PSScriptRoot}\..\..\Applications\Authenticate-DockerForGoogleArtifactRegistry.ps1
    . ${PSScriptRoot}\..\Run\Run-SwarmAgent.ps1

    $JenkinsAgentFolder = "C:\J"
    $JenkinsWorkspaceFolder = "C:\W"
    $PlasticConfigFolder = "C:\PlasticConfig"

    Write-Host "Ensuring that the boot partition uses the entire boot disk..."

    # If the instance has been created with a boot disk that is larger than the original machine image,
    #  then the boot partition remains the original size; we must manually expand it
    #
    # This should ideally be done on instance start (as opposed to on service start) as this adds another
    #  ~5 seconds to each service start. We are doing it here to keep things simple.
     Resize-PartitionToMaxSize -DriveLetter "C"

    $AgentName = (Get-GCEInstanceHostname).Split(".")[0]

    # Fetch configuration parameters repeatedly, until all are available
    while ($true) {

        Write-Host "Retrieving configuration from Secrets Manager..."

        $JenkinsURL = Get-GCESecret -Key "jenkins-url"
        $AgentKey = Get-GCESecret -Key "agent-key-file"
        $AgentImageURL = Get-GCESecret -Key "swarm-agent-image-url-windows"
        $AgentUsername = Get-GCESecret -Key "swarm-agent-username"
        $AgentAPIToken = Get-GCESecret -Key "swarm-agent-api-token"
        $PlasticConfigZip = Get-GCESecret -Key "plastic-config-zip" -Binary $true
        $Labels = Get-GCEInstanceMetadata -Key "jenkins-labels"

        Write-Host "Required settings:"
        Write-Host "Secret jenkins-url: $(if ($JenkinsURL -ne $null) { "found" } else { "not found" })"
        Write-Host "Secret agent-key-file: $(if ($AgentKey -ne $null) { "found" } else { "not found" })"
        Write-Host "Secret agent-image-url-windows: $(if ($AgentImageURL -ne $null) { "found" } else { "not found" })"
        Write-Host "Secret swarm-agent-username: $(if ($AgentUsername -ne $null) { "found" } else { "not found" })"
        Write-Host "Secret swarm-agent-api-token: $(if ($AgentAPIToken -ne $null) { "found" } else { "not found" })"
        Write-Host "Instance metadata jenkins-labels: $(if ($Labels -ne $null) { "found" } else { "not found" })"
        Write-Host "Optional settings:"
        Write-Host "Secret plastic-config-zip: $(if ($PlasticConfigZip -ne $null) { "found" } else { "not found" })"

        if (($JenkinsURL -ne $null) -and ($AgentImageURL -ne $null) -and ($AgentKey -ne $null) -and ($AgentUsername -ne $null) -and ($AgentAPIToken -ne $null) -and ($Labels -ne $null)) {
            break
        } else {
            Write-Host "Some required secrets/instance metadata are missing. Sleeping, then retrying..."
            Start-Sleep 10
        }
    }

    if ($PlasticConfigZip) {
        Write-Host "Deploying Plastic SCM client configuration..."

        $PlasticConfigZipLocation = "${PSScriptRoot}\plastic-config.zip"
        try {
            [IO.File]::WriteAllBytes($PlasticConfigZipLocation, $PlasticConfigZip)
            Expand-Archive -LiteralPath $PlasticConfigZipLocation -DestinationPath "C:\PlasticConfig" -Force -ErrorAction Stop
        } finally {
            Remove-Item $PlasticConfigZipLocation -ErrorAction SilentlyContinue
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
        PlasticConfigFolder = $PlasticConfigFolder
        JenkinsURL = $JenkinsURL
        AgentUsername = $AgentUsername
        AgentAPIToken = $AgentAPIToken
        AgentImageURL = $AgentImageURL
        NumExecutors = 1
        Labels = $Labels
        AgentName = $AgentName
    }

    Run-SwarmAgent @ServiceParams

    Write-Host "Done."

} finally {

    Stop-Transcript

}