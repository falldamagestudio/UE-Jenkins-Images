# Install Pester (latest version, v5.0.0 or newer)
Install-Module -Name Pester -Force -SkipPublisherCheck -MinimumVersion 5.0.0 -ErrorAction Stop
Get-Module -Name Pester | Remove-Module
Import-Module -Name Pester -MinimumVersion 5.0.0 -ErrorAction Stop

# Install https://github.com/nohwnd/Assert
Install-Module -Name Assert -Force -MinimumVersion 0.9.5 -ErrorAction Stop
Get-Module -Name Assert | Remove-Module
Import-Module Assert -ErrorAction Stop