# Log all output to file (in addition to console output, when run manually )
# This enables post-mortem inspection of the script's activities via log files
# It also allows GCE's logging agent to pick up the activity and forward it to Google's Cloud Logging
Start-Transcript -LiteralPath "C:\Logs\GCEService-VM-Startup-$(Get-Date -Format "yyyyMMdd-HHmmss" -ErrorAction Stop).txt" -ErrorAction Stop

try {

    . ${PSScriptRoot}\..\..\SystemConfiguration\Resize-PartitionToMaxSize.ps1
    . ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESettings.ps1
    . ${PSScriptRoot}\..\..\Applications\Deploy-PlasticClientConfig.ps1

    Write-Host "Waiting for SSH public key to be available in Secrets manager..."

    $RequiredSettingsSpec = @{
        SshPublicKey = @{ Name = "ssh-vm-public-key-windows"; Source = [GCESettingSource]::Secret }
    }

    $RequiredSettings = Get-GCESettings $RequiredSettingsSpec -Wait -PrintProgress

    Write-Host "Setting up SSH public key..."

    Set-Content -Path $env:PROGRAMDATA\ssh\administrators_authorized_keys -Value $RequiredSettings.SshPublicKey -ErrorAction Stop

    # Fix up permissions on authorized_keys.
    # https://github.com/jenkinsci/google-compute-engine-plugin/blob/develop/windows-image-install.ps1
    # https://www.concurrency.com/blog/may-2019/key-based-authentication-for-openssh-on-windows
    icacls $env:PROGRAMDATA\ssh\administrators_authorized_keys /inheritance:r
    icacls $env:PROGRAMDATA\ssh\administrators_authorized_keys /grant SYSTEM:`(F`)
    icacls $env:PROGRAMDATA\ssh\administrators_authorized_keys /grant BUILTIN\Administrators:`(F`)

    Write-Host "Fetching Plastic config from Secrets Manager..."

    $OptionalSettingsSpec = @{
        PlasticConfigZip = @{ Name = "plastic-config-zip"; Source = [GCESettingSource]::Secret; Binary = $true }
    }

    $OptionalSettings = Get-GCESettings $OptionalSettingsSpec -PrintProgress

    if ($OptionalSettings.PlasticConfigZip) {
        Write-Host "Deploying Plastic SCM client configuration..."

        Deploy-PlasticClientConfig -ZipContent $OptionalSettings.PlasticConfigZip -ConfigFolder $DefaultFolders.PlasticConfigFolder
    }

    Write-Host "Starting up SSH server..."

    Start-Service -Name "sshd"

    # Jenkins can now connect to the instance via SSH (so the GCE plugin can now connect and start the agent)

    Write-Host "Ensuring that the boot partition uses the entire boot disk..."

    # If the instance has been created with a boot disk that is larger than the original machine image,
    #  then the boot partition remains the original size; we must manually expand it
    Resize-PartitionToMaxSize -DriveLetter "C"

    Write-Host "Done."

} finally {

    Stop-Transcript

}
