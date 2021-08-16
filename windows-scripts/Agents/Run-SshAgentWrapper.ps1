param (
    [Parameter(Mandatory=$false)] [string] $jar,
    [Parameter(Mandatory=$false)] [Switch] $fullversion
)

# Log all output to file (in addition to console output, when run manually )
# This enables post-mortem inspection of the script's activities via log files
# It also allows GCE's logging agent to pick up the activity and forward it to Google's Cloud Logging
Start-Transcript -LiteralPath "$(Resolve-Path "${PSScriptRoot}\..\Logs")\Run-SshAgentWrapper-$(Get-Date -Format "yyyyMMdd-HHmmss").txt"

try {

    . ${PSScriptRoot}\..\Tools\Scripts\Get-GCESecret.ps1
    . ${PSScriptRoot}\..\Tools\Scripts\Authenticate-DockerForGoogleArtifactRegistry.ps1
    . ${PSScriptRoot}\..\Tools\Scripts\Run-SshAgent.ps1

    # Respond to version query; the GCE plugin does this to verify that the java executable is present, and doesn't care about the actual version number
    if ($fullversion) {
        Write-Host "java-to-docker shim"
        return
    }

    # If it isn't a version query, then we require it to be a launch command
    if (!$jar) {
        Write-Host "Error: java-to-docker shim should be executed like this: /run/jenkins-agent-wrapper.sh -jar <path to agent.jar>"
        throw "Error: java-to-docker shim should be executed like this: /run/jenkins-agent-wrapper.sh -jar <path to agent.jar>"
    }

    $JenkinsAgentFolder = "C:\J"
    $JenkinsWorkspaceFolder = "C:\W"
    $PlasticConfigFolder = "C:\PlasticConfig"

    $AgentJarFolder = "C:\AgentJar"
    $AgentJarFile = "C:\AgentJar\agent.jar"

    # Fetch configuration parameters repeatedly, until all are available
    while ($true) {

        Write-Host "Retrieving configuration from Secrets Manager..."

        $AgentKey = Get-GCESecret -Key "agent-key-file"
        $AgentImageURL = Get-GCESecret -Key "ssh-agent-image-url-windows"
        $PlasticConfigZip = Get-GCESecret -Key "plastic-config-zip" -Binary $true
 
        Write-Host "Required settings:"
        Write-Host "Secret agent-key-file: $(if ($AgentKey -ne $null) { "found" } else { "not found" })"
        Write-Host "Secret ssh-agent-image-url-windows: $(if ($AgentImageURL -ne $null) { "found" } else { "not found" })"
        Write-Host "Optional settings:"
        Write-Host "Secret plastic-config-zip: $(if ($PlasticConfigZip -ne $null) { "found" } else { "not found" })"

        if (($AgentImageURL -ne $null) -and ($AgentKey -ne $null)) {
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

    Write-Host "Copying provided agent jar to $AgentJarFile..."

    New-Item -ItemType Directory -Path $AgentJarFolder -Force -ErrorAction Stop | Out-Null
    Copy-Item $jar $AgentJarFile -ErrorAction Stop

    Write-Host "Running Jenkins Agent..."

    $ServiceParams = @{
        JenkinsAgentFolder = $JenkinsAgentFolder
        JenkinsWorkspaceFolder = $JenkinsWorkspaceFolder
        PlasticConfigFolder = $PlasticConfigFolder
        AgentImageURL = $AgentImageURL
        AgentJarFolder = $AgentJarFolder
        AgentJarFile = $AgentJarFile
    }

    Run-SshAgent @ServiceParams

    Write-Host "Done."

} finally {

    Stop-Transcript

}
