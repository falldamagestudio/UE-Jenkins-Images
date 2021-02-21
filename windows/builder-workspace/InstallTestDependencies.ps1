# Install Pester (latest version, v5.0.0 or newer)
Write-Host "PSVersion:"
$PSVersionTable.PSVersion | Out-Host
Find-Module -Name Pester -Verbose | Out-Host
Get-Module -Name Pester -Verbose | Out-Host
Get-Command -Module pester | Select-Object -Property name, version -First 3 | Out-Host
Install-Module -Name Pester -Force -SkipPublisherCheck -ErrorAction Stop -Verbose | Out-Host
Get-Module -Name Pester -Verbose | Out-Host
Get-Command -Module pester -Verbose | Select-Object -Property name, version -First 3 | Out-Host
Import-Module -Name Pester -RequiredVersion 5.1.1 -ErrorAction Stop -Verbose | Out-Host
Get-Module -Name Pester -Verbose | Out-Host
Get-Command -Module pester -Verbose | Select-Object -Property name, version -First 3 | Out-Host

# Install https://github.com/nohwnd/Assert
Install-Module -Name Assert -Force -ErrorAction Stop
Import-Module Assert -ErrorAction Stop

Get-Module -Name Assert -Verbose | Out-Host
