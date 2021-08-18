# Log all output to file (in addition to console output, when run manually )
# This enables post-mortem inspection of the script's activities via log files
# It also allows GCE's logging agent to pick up the activity and forward it to Google's Cloud Logging
Start-Transcript -LiteralPath "C:\Logs\GCEService-DockerInboundAgent-$(Get-Date -Format "yyyyMMdd-HHmmss").txt"

try {

    . ${PSScriptRoot}\..\..\SystemConfiguration\Resize-PartitionToMaxSize.ps1
    . ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESecret.ps1
    . ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCEInstanceHostname.ps1
    . ${PSScriptRoot}\..\..\Applications\Authenticate-DockerForGoogleArtifactRegistry.ps1
    . ${PSScriptRoot}\..\Run\Run-DockerInboundAgent.ps1

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
        $AgentImageURL = Get-GCESecret -Key "inbound-agent-image-url-windows"
        $JenkinsSecret = Get-GCESecret -Key "inbound-agent-secret-${AgentName}"
        $PlasticConfigZip = Get-GCESecret -Key "plastic-config-zip" -Binary $true

        Write-Host "Required settings:"
        Write-Host "Secret jenkins-url: $(if ($JenkinsURL -ne $null) { "found" } else { "not found" })"
        Write-Host "Secret agent-key-file: $(if ($AgentKey -ne $null) { "found" } else { "not found" })"
        Write-Host "Secret inbound-agent-image-url-windows: $(if ($AgentImageURL -ne $null) { "found" } else { "not found" })"
        Write-Host "Secret inbound-agent-secret-${AgentName}: $(if ($JenkinsSecret -ne $null) { "found" } else { "not found" })"
        Write-Host "Optional settings:"
        Write-Host "Secret plastic-config-zip: $(if ($PlasticConfigZip -ne $null) { "found" } else { "not found" })"

        if (($JenkinsURL -ne $null) -and ($AgentImageURL -ne $null) -and ($AgentKey -ne $null) -and ($JenkinsSecret -ne $null)) {
            break
        } else {
            Write-Host "Some required secrets are missing. Sleeping, then retrying..."
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
        JenkinsSecret = $JenkinsSecret
        AgentImageURL = $AgentImageURL
        AgentName = $AgentName
    }

    Run-DockerInboundAgent @ServiceParams

    Write-Host "Done."

} finally {

    Stop-Transcript

}