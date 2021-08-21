. ${PSScriptRoot}\Get-GCESecret.ps1
. ${PSScriptRoot}\Get-GCEInstanceMetadata.ps1

enum GCESettingSource {
    Secret
    InstanceMetadata
}

class GetGCESettingException : Exception {
    $Key
    $Source

    GetGCESettingException([string] $key, [string] $source) : base("Get-GCESettings has been called with an entry that has invalid source set; Key = ${key}, Source = ${source}") { $this.Key = $key; $this.Source = $source }
}

. ${PSScriptRoot}\Get-GCESecret.ps1

function Get-GCESettings {
    param (
		[Parameter(Mandatory=$true)] [Hashtable] $Settings,
        [Parameter(Mandatory=$false)] [Switch] $Wait=$false,
        [Parameter(Mandatory=$false)] [Switch] $PrintProgress=$false
    )

    $Delay = 10     # Number of seconds to wait between each attempt if

    while ($true) {

        # Fetch each of the settings from Secrets Manager / Instance Metadata and construct a result map

        $AllSettingsFound = $true
        $Result = @{}
        foreach ($Setting in $Settings.GetEnumerator()) {
            $Key = $Setting.Value.Name

            $SettingValue = $null
            switch ($Setting.Value.Source) {
                Secret {
                    $Binary = ($Setting.Value.ContainsKey('Binary') -and $Setting.Value.Binary)            
                    $SettingValue = Get-GCESecret -Key $Key -Binary $Binary
                }
                InstanceMetadata {
                    $SettingValue = Get-GCEInstanceMetadata -Key $Key
                }
                default {
                    throw [GetGCESettingException]::new($Key, $Setting.Value.Source)
                }
            }

            $Result[$Setting.Key] = $SettingValue
            if (!$SettingValue) {
                $AllSettingsFound = $false
            }
        }

        # Print results, if requested

        if ($PrintProgress) {
            foreach ($Setting in $Settings.GetEnumerator()) {
                Write-Host "Setting ${Setting.Value.Source} ${Setting.Value.Name}: $(if ($Result[$Setting.Key]) { "found" } else { "not found" })"
            }

            if ($AllSettingsFound) {
                Write-Host "All settings found"
            }
        }

        # Are we done yet?

        if (!$Wait -or $AllSettingsFound) {

            # Done!

            return $Result

        } else {

            # Not done, sleep and try again

            if ($PrintProgress) {
                Write-Host "Some required settings are missing. Sleeping for ${Delay} seconds, then retrying..."
            }

            Start-Sleep $Delay -ErrorAction Stop
        }
    }
}