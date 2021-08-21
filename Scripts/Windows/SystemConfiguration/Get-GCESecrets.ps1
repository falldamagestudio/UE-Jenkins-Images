function Get-GCESecrets {
    param (
		[Parameter(Mandatory=$true)] [Hashtable] $Secrets,
        [Parameter(Mandatory=$false)] [Switch] $Wait=$false,
        [Parameter(Mandatory=$false)] [Switch] $PrintProgress=$false
    )

    $Delay = 10     # Number of seconds to wait between each attempt if

    while ($true) {

        # Fetch each of the secrets from Secrets Manager and construct a result map

        $AllSecretsFound = $true
        $Result = @{}
        foreach ($Secret in $Secrets.GetEnumerator()) {
            $Key = $Secret.Value.Name
            $Binary = ($Secret.Value.ContainsKey('Binary') -and $Secret.Value.Binary)            
            $SecretValue = Get-GCESecret -Key $Key -Binary $Binary
            $Result[$Secret.Key] = $SecretValue
            if (!$SecretValue) {
                $AllSecretsFound = $false
            }
        }

        # Print results, if requested

        if ($PrintProgress) {
            foreach ($Secret in $Secrets.GetEnumerator()) {
                Write-Host "Secret ${Secret.Value.Name}: $(if ($Result[$Secret.Key]) { "found" } else { "not found" })"
            }

            if ($AllSecretsFound) {
                Write-Host "All secrets found"
            }
        }

        # Are we done yet?

        if (!$Wait -or $AllSecretsFound) {

            # Done!

            return $Result

        } else {

            # Not done, sleep and try again

            if ($PrintProgress) {
                Write-Host "Some required secrets are missing. Sleeping for ${Delay} seconds, then retrying..."
            }

            Start-Sleep $Delay -ErrorAction Stop
        }
    }
}