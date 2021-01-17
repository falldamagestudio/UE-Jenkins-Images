param (
	[Parameter(Mandatory=$true)][string]$ImageName,
	[Parameter(Mandatory=$true)][string]$ImageTag
)

# Push built container image to remote registry

& docker push "${ImageName}:${ImageTag}"
