# Log all output to file (in addition to console output, when run manually )
# This enables post-mortem inspection of the script's activities via log files
# It also allows GCE's logging agent to pick up the activity and forward it to Google's Cloud Logging
Start-Transcript -LiteralPath "$(Resolve-Path "${PSScriptRoot}\..\Logs")\GCEService-Sshd-$(Get-Date -Format "yyyyMMdd-HHmmss").txt"

try {

    . ${PSScriptRoot}\..\Tools\Scripts\Resize-PartitionToMaxSize.ps1
    . ${PSScriptRoot}\..\Tools\Scripts\Get-GCESecret.ps1

    Write-Host "Ensuring that the boot partition uses the entire boot disk..."

    # If the instance has been created with a boot disk that is larger than the original machine image,
    #  then the boot partition remains the original size; we must manually expand it
    #
    # This should ideally be done on instance start (as opposed to on service start) as this adds another
    #  ~5 seconds to each service start. We are doing it here to keep things simple.
    Resize-PartitionToMaxSize -DriveLetter "C"

    # Fetch configuration parameters repeatedly, until all are available
    while ($true) {

        Write-Host "Retrieving sshd configuration from Secrets Manager..."

        $SshPublicKey = Get-GCESecret -Key "ssh-vm-public-key-windows"

        Write-Host "Secret ssh-vm-public-key-windows: $(if ($SshPublicKey -ne $null) { "found" } else { "not found" })"

        if (($SshPublicKey -ne $null)) {
            break
        } else {
            Write-Host "Some required secrets are missing. Sleeping, then retrying..."
            Start-Sleep 10
        }
    }

    Write-Host "Setting up SSH public key..."

    Set-Content -Path $env:PROGRAMDATA\ssh\administrators_authorized_keys -Value $SshPublicKey -ErrorAction Stop

    # Fix up permissions on authorized_keys.
    # https://github.com/jenkinsci/google-compute-engine-plugin/blob/develop/windows-image-install.ps1
    # https://www.concurrency.com/blog/may-2019/key-based-authentication-for-openssh-on-windows
    icacls $env:PROGRAMDATA\ssh\administrators_authorized_keys /inheritance:r
    icacls $env:PROGRAMDATA\ssh\administrators_authorized_keys /grant SYSTEM:`(F`)
    icacls $env:PROGRAMDATA\ssh\administrators_authorized_keys /grant BUILTIN\Administrators:`(F`)

    Write-Host "Starting SSH service..."

    Start-Service -Name sshd -ErrorAction Stop

    Write-Host "SSH service is accepting incoming connections."

    (Get-Service -Name sshd -ErrorAction Stop).WaitForStatus('Stopped')

    Write-Host "SSH service has been stopped."

} finally {

    Stop-Transcript

}
