. ${PSScriptRoot}\..\SystemConfiguration\Add-WindowsDefenderExclusionRule.ps1

function BuildStep-CreateAgentHostFolders {

    $VMSettings = Import-PowerShellDataFile "${PSScriptRoot}\..\VMSettings.psd1"

    Write-Host "Creating folders for logs..."

    New-Item -ItemType Directory -Path $VMSettings.ServiceWrapperLogsFolder -ErrorAction Stop | Out-Null
    
    Write-Host "Creating folders for Jenkins..."
    
    New-Item -ItemType Directory -Path $VMSettings.JenkinsAgentFolder -ErrorAction Stop | Out-Null
    New-Item -ItemType Directory -Path $VMSettings.JenkinsWorkspaceFolder -ErrorAction Stop | Out-Null

    Write-Host "Creating config folder for Plastic SCM..."

    New-Item -ItemType Directory -Path $VMSettings.PlasticConfigFolder -ErrorAction Stop | Out-Null
    
    Write-Host "Adding Windows Defender exclusion rule for Jenkins-related folders..."

    Add-WindowsDefenderExclusionRule -Folder $VMSettings.JenkinsAgentFolder -ErrorAction Stop
    Add-WindowsDefenderExclusionRule -Folder $VMSettings.JenkinsWorkspaceFolder -ErrorAction Stop
}
