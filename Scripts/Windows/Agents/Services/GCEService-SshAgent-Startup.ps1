# Log all output to file (in addition to console output, when run manually )
# This enables post-mortem inspection of the script's activities via log files
# It also allows GCE's logging agent to pick up the activity and forward it to Google's Cloud Logging
Start-Transcript -LiteralPath "C:\Logs\GCEService-SshAgent-Startup-$(Get-Date -Format "yyyyMMdd-HHmmss" -ErrorAction Stop).txt" -ErrorAction Stop

try {

    . ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESettings.ps1
    . ${PSScriptRoot}\..\..\Applications\Deploy-PlasticClientConfig.ps1

    $DefaultFolders = Import-PowerShellDataFile -Path "${PSScriptRoot}\..\..\BuildSteps\DefaultBuildStepSettings.psd1" -ErrorAction Stop

    Write-Host "Fetching optional settings from Secrets Manager / Instance Metadata..."

    $OptionalSettingsSpec = @{
        PlasticConfigZip = @{ Name = "plastic-config-zip"; Source = [GCESettingSource]::Secret; Binary = $true }
    }

    $OptionalSettings = Get-GCESettings $OptionalSettingsSpec -PrintProgress

    if ($OptionalSettings.PlasticConfigZip) {
        Write-Host "Deploying Plastic SCM client configuration..."

        Deploy-PlasticClientConfig -ZipContent $OptionalSettings.PlasticConfigZip -ConfigFolder $DefaultFolders.PlasticConfigFolder
    }

    Write-Host "Done."

} finally {

    Stop-Transcript

}