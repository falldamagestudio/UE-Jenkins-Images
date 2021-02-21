# Install Pester (latest version, v5.0.0 or newer)
Write-Host "PSVersion:"
$PSVersionTable.PSVersion | Out-Host
Find-Module -Name Pester | Out-Host
Get-Module -Name Pester | Out-Host
Get-Command -Module pester | Select-Object -Property name, version -First 3 | Out-Host
Install-Module -Name Pester -Force -SkipPublisherCheck -ErrorAction Stop
Get-Module -Name Pester | Out-Host
Get-Command -Module pester | Select-Object -Property name, version -First 3 | Out-Host
Import-Module Pester -ErrorAction Stop
Get-Module -Name Pester | Out-Host
Get-Command -Module pester | Select-Object -Property name, version -First 3 | Out-Host

# Install https://github.com/nohwnd/Assert
Install-Module -Name Assert -Force -ErrorAction Stop
Import-Module Assert -ErrorAction Stop
