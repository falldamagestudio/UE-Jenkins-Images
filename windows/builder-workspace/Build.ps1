param (
	[Parameter(Mandatory=$true)][string]$GceRegion,
	[Parameter(Mandatory=$true)][string]$ImageName,
	[Parameter(Mandatory=$true)][string]$ImageTag
)

& "${PSScriptRoot}\SetupDockerRegistryAuthentication.ps1" -GceRegion ${GceRegion}

& "${PSScriptRoot}\BuildImage.ps1" -ImageName ${ImageName} -ImageTag ${ImageTag}

& "${PSScriptRoot}\PushImage.ps1" -ImageName ${ImageName} -ImageTag ${ImageTag}
