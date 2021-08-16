function Get-GCEInstanceHostname {

	<#
		.SYNOPSIS
		Fetches the internal DNS name of the current instance.
        It will be on the form <instance shortname>.c.<project>.internal
	#>

	$Result = try { Invoke-RestMethod -Uri "http://metadata.google.internal/computeMetadata/v1/instance/hostname" -Headers @{ "Metadata-Flavor" = "Google" } -ErrorAction Stop } catch { $null }

    return $Result
}
