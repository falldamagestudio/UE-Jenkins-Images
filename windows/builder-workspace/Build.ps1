param (
	[Parameter(Mandatory=$true)][string]$GceRegion,
	[Parameter(Mandatory=$true)][string]$ImageName,
	[Parameter(Mandatory=$true)][string]$ImageTag
)

. "${PSScriptRoot}\Resize-PartitionToMaxSize.ps1"
Resize-PartitionToMaxSize -DriveLetter C

& "${PSScriptRoot}\InstallTestDependencies.ps1"

& "${PSScriptRoot}\RunTests.ps1"

& "${PSScriptRoot}\SetupDockerRegistryAuthentication.ps1" -GceRegion ${GceRegion}

& "${PSScriptRoot}\BuildImage.ps1" -ImageName ${ImageName} -ImageTag ${ImageTag}

& "${PSScriptRoot}\PushImage.ps1" -ImageName ${ImageName} -ImageTag ${ImageTag}
