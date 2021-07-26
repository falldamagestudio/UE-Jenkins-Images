function Install-Chocolatey {
 
    # Install Chocolatey
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));

    # Refresh environment (so 'choco' is on the path)
    RefreshEnv.cmd
}