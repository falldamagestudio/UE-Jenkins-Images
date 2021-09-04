param (
    [Parameter(Mandatory=$false)] [string] $jar,
    [Parameter(Mandatory=$false)] [Switch] $fullversion
)

# Log all output to file (in addition to console output, when run manually )
# This enables post-mortem inspection of the script's activities via log files
# It also allows GCE's logging agent to pick up the activity and forward it to Google's Cloud Logging
# TODO: decide on a better path for logs
Start-Transcript -LiteralPath "C:\Logs\Run-JavaShim-DockerSshAgent-$(Get-Date -Format "yyyyMMdd-HHmmss" -ErrorAction Stop).txt" -ErrorAction Stop

try {

    . ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESettings.ps1
    . ${PSScriptRoot}\..\..\Applications\Authenticate-DockerForGoogleArtifactRegistry.ps1
    . ${PSScriptRoot}\..\Run\Run-DockerSshAgent.ps1

    $VMSettings = Import-PowerShellDataFile "${PSScriptRoot}\..\..\VMSettings.psd1" -ErrorAction Stop

    # Respond to version query; the GCE plugin does this to verify that the java executable is present, and doesn't care about the actual version number
    if ($fullversion) {
        Write-Host "java-to-docker shim"
        return
    }

    # If it isn't a version query, then we require it to be a launch command
    if (!$jar) {
        Write-Host "Error: java-to-docker shim should be executed like this: java -jar <path to agent.jar>"
        throw "Error: java-to-docker shim should be executed like this: java -jar <path to agent.jar>"
    }

    # Ensure agent file is placed within a folder that will be host-mounted
    #  into the agent container
    $AgentJarFolder = $VMSettings.JenkinsAgentFolder
    $AgentJarFile = "${AgentJarFolder}\agent.jar"


    Write-Host "Waiting for required settings to be available in Secrets Manager / Instance Metadata..."

    $RequiredSettingsSpec = @{
        AgentKey = @{ Name = "agent-key-file"; Source = [GCESettingSource]::Secret }
        AgentImageURL = @{ Name = "ssh-agent-image-url-windows"; Source = [GCESettingSource]::Secret }
    }

    $RequiredSettings = Get-GCESettings $RequiredSettingsSpec -Wait -PrintProgress

    # Extract region from docker image URL
    # Example: europe-west1-docker.pkg.dev/<projectname>/<reponame>/<imagename>:<tag> => europe-west1
    $Region = ($RequiredSettings.AgentImageURL -Split "-docker.pkg.dev")[0]

    Write-Host "Authenticating Docker for Google Artifact Registry..."

    Authenticate-DockerForGoogleArtifactRegistry -AgentKey $RequiredSettings.AgentKey -Region $Region

    Write-Host "Copying provided agent jar to ${AgentJarFile}..."

    Copy-Item $jar $AgentJarFile -ErrorAction Stop

    Write-Host "Running Jenkins Agent..."

    $ServiceParams = @{
        JenkinsAgentFolder = $VMSettings.JenkinsAgentFolder
        JenkinsWorkspaceFolder = $VMSettings.JenkinsWorkspaceFolder
        PlasticConfigFolder = $VMSettings.PlasticConfigFolder
        AgentImageURL = $RequiredSettings.AgentImageURL
        AgentJarFile = $AgentJarFile
    }

    Run-DockerSshAgent @ServiceParams

    Write-Host "Done."

} finally {

    Stop-Transcript

}
