function Authenticate-GoogleCloudADC {

	<#
		.SYNOPSIS
		Configures Application Default Credentials to use a given service account
	#>

	param (
		[Parameter(Mandatory)] [string] $AgentKey
	)

	$AgentKey | Out-File -FilePath "${env:APPDATA}\gcloud\application_default_credentials.json" -ErrorAction Stop
}
