# Install Pester (latest version, v5.0.0 or newer)
Install-Module -Name Pester -Force -SkipPublisherCheck -ErrorAction Stop
Import-Module Pester -ErrorAction Stop

# Install https://github.com/nohwnd/Assert
Install-Module -Name Assert -Force -ErrorAction Stop
Import-Module Assert -ErrorAction Stop
