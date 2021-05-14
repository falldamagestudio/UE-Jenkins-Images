. ${PSScriptRoot}\Invoke-External-WithStdio.ps1

function Get-GCESecret {

	<#
		.SYNOPSIS
		Reads the value of a GCE secret.

		The result can be returned either as a character string,
		or as a binary array (suitable for binary output)
	#>

	param (
		[Parameter(Mandatory=$true)][string]$Key,
		[Parameter(Mandatory=$false)][bool]$Binary=$false,
		[Parameter(Mandatory=$false)][Text.Encoding]$Encoding=[Text.Encoding]::ASCII
	)

	$Metadata = "http://metadata.google.internal/computeMetadata/v1"

	# Fetch access token for google APIs
	$AccessToken = (Invoke-RestMethod -Uri "${Metadata}/instance/service-accounts/default/token" -Headers @{ "Metadata-Flavor" = "Google" } -ErrorAction Stop).access_token
	#Typical response format from Invoke-RestMethod call:
	#   {
	#     "name": "projects/<id>/secrets/<name>/versions/1",
	#     "payload": {
	#       "data": "<base64 encoded string>"
	#     }
	#   }

    $Project = Invoke-RestMethod -Uri "${Metadata}/project/project-id" -Headers @{ "Metadata-Flavor" = "Google" } -ErrorAction Stop

	$SecretResponse = try { Invoke-RestMethod -Uri "https://secretmanager.googleapis.com/v1/projects/${Project}/secrets/${Key}/versions/latest:access" -Headers @{ "Authorization" = "Bearer ${AccessToken}" } -ErrorAction Stop } catch { $null }

	# Typical error format from Invoke-RestMethod call:
	# { "error": { "code": 403, "message": "Permission 'secretmanager.versions.access' denied for resource 'projects/<project>/secrets/<key>/versions/latest' (or it may not exist).", "status": "PERMISSION_DENIED" } }
	#  ... and Invoke-RestMethod will throw InvalidOperation for non-200 responses, so we convert that into a blank entry
	#
	# Typical success format from Invoke-RestMethod call:
	# { "name": "projects/<projectid>/secrets/<key>/versions/<id>", "payload": { "data": "<base64 encoded string>" } }
	if ($SecretResponse) {

		# Secret has been retrieved successfully
		$SecretValueBinary = [Convert]::FromBase64String($SecretResponse.payload.data)

		if ($Binary) {
			# Return secret as a char array
			return $SecretValueBinary
		} else {
			# Return secret as text string, parsed with the given encoding
			return $Encoding.GetString($SecretValueBinary)
		}

	} else {

		# Unable to access secret; either permissions error, or the secret does not exist
		return $null
	}
}
