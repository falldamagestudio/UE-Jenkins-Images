. ${PSScriptRoot}\..\SystemConfiguration\Add-WindowsDefenderExclusionRule.ps1

function BuildStep-CreateAgentHostFolders {

    $DefaultFolders = Import-PowerShellDataFile "${PSScriptRoot}\DefaultBuildStepSettings.psd1"

    Write-Host "Creating folders for logs..."

    New-Item -ItemType Directory -Path $DefaultFolders.ServiceWrapperLogsFolder -ErrorAction Stop | Out-Null
    
    Write-Host "Creating folders for Jenkins..."
    
    New-Item -ItemType Directory -Path $DefaultFolders.JenkinsAgentFolder -ErrorAction Stop | Out-Null
    New-Item -ItemType Directory -Path $DefaultFolders.JenkinsWorkspaceFolder -ErrorAction Stop | Out-Null

    Write-Host "Creating config folder for Plastic SCM..."

    New-Item -ItemType Directory -Path $DefaultFolders.PlasticConfigFolder -ErrorAction Stop | Out-Null
    
    Write-Host "Adding Windows Defender exclusion rule for Jenkins-related folders..."

    Add-WindowsDefenderExclusionRule -Folder $DefaultFolders.JenkinsAgentFolder -ErrorAction Stop
    Add-WindowsDefenderExclusionRule -Folder $DefaultFolders.JenkinsWorkspaceFolder -ErrorAction Stop
}
