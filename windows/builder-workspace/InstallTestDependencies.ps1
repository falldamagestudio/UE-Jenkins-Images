# Install Pester (latest version, v5.0.0 or newer)
Get-Module -Name Pester
Get-Command -Module pester | Select-Object -Property name, version -First 3
Install-Module -Name Pester -Force -SkipPublisherCheck -ErrorAction Stop
Get-Module -Name Pester
Get-Command -Module pester | Select-Object -Property name, version -First 3
Import-Module Pester -ErrorAction Stop
Get-Module -Name Pester
Get-Command -Module pester | Select-Object -Property name, version -First 3

# Install https://github.com/nohwnd/Assert
Install-Module -Name Assert -Force -ErrorAction Stop
Import-Module Assert -ErrorAction Stop
