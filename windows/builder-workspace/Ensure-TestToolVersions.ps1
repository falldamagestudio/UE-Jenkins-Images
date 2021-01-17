$MinimumPesterVersion = "5.0.0"

if (!(Get-Module -Name Pester -ListAvailable) -Or ((Get-Module -Name Pester -ListAvailable)[0].Version -lt [version]${MinimumPesterVersion})) {
	throw "Pester ${MinimumPesterVersion} or later is required. Please see https://pester.dev/docs/introduction/installation for installation instructions."
}

$MinimumAssertVersion = "0.9.5"

if (!(Get-Module -Name Assert -ListAvailable) -Or ((Get-Module -Name Assert -ListAvailable)[0].Version -lt [version]${MinimumAssertVersion})) {
	throw "Assert ${MinimumAssertVersion} or later is required. Please see https://github.com/nohwnd/Assert for installation instructions."
}