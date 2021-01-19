param (
	[Parameter(Mandatory=$true)][string]$GceRegion
)

$DockerCredentialGcrDownloadURL = "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v2.0.2/docker-credential-gcr_windows_amd64-2.0.2.tar.gz"
$ServiceAccountKeyFile = ".\service-account-key.json"

# Download docker-credential-gcr

Invoke-WebRequest -Uri ${DockerCredentialGcrDownloadURL} -OutFile docker-credential-gcr.tgz -ErrorAction Stop
& tar -xzvf docker-credential-gcr.tgz

# Configure docker to use docker-credential gcr for authentication

& .\docker-credential-gcr.exe configure-docker --registries ${GceRegion}-docker.pkg.dev

# Use service account file for authentication

$GCloudConfigFolder = "${env:APPDATA}\gcloud"

if (!(Test-Path $GCloudConfigFolder)) {
	New-Item -Type Directory $GCloudConfigFolder -ErrorAction Stop | Out-Null
}

Copy-Item -Path .\service-account-key.json -Destination "${GCloudConfigFolder}\application_default_credentials.json" -ErrorAction Stop