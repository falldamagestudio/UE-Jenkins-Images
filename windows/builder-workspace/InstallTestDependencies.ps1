# Install Pester (latest version, v5.0.0 or newer)
Install-Module -Name Pester -Force -SkipPublisherCheck -MinimumVersion 5.0.0 -ErrorAction Stop -Verbose | Out-Host
Get-Module -Name Pester | Remove-Module
Import-Module -Name Pester -MinimumVersion 5.0.0 -ErrorAction Stop -Verbose | Out-Host
Get-Module -Name Pester -Verbose | Out-Host
Get-Command -Module pester -Verbose | Select-Object -Property name, version -First 3 | Out-Host

# Install https://github.com/nohwnd/Assert
Install-Module -Name Assert -Force -MinimumVersion 0.9.5 -ErrorAction Stop
Get-Module -Name Assert | Remove-Module
Import-Module Assert -ErrorAction Stop

Get-Module -Name Assert -Verbose | Out-Host
