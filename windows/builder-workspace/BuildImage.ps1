param (
	[Parameter(Mandatory=$true)][string]$ImageName,
	[Parameter(Mandatory=$true)][string]$ImageTag
)

# Install DirectX Redistributable
# This is the only officially supported way to get hold of xinput1_3.dll
#  (the .DLL file needs to be present within the container, but the redist installer cannot
#  be executed within the container - so we run the installer on the host OS, and we can then
#  fetch the DLL from the host filesystem, and provide that to the container build process)

. ${PSScriptRoot}\Install-DirectXRedistributable.ps1

Install-DirectXRedistributable

# Provide xinput1_3.dll from host OS to the container build process

Copy-Item C:\Windows\System32\xinput1_3.dll Container

# Build container image

& docker build -t "${ImageName}:${ImageTag}" -f ue-jenkins-buildtools-windows.Dockerfile .
