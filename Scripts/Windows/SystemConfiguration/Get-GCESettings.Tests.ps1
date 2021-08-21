. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Get-GCESecret.ps1
	. ${PSScriptRoot}\Get-GCESettings.ps1

}

Describe 'Get-GCESettings' {

    It "Returns null-valued secret if value does not exist" {

        Mock Get-GCESecret -ParameterFilter { $Key -eq "gcesecretname" } { $null }
        Mock Get-GCESecret { throw "Invalid invocation of Get-GCESecret" }
        Mock Get-GCEInstanceMetadata { throw "Get-GCEInstanceMetadata should not be called" }
        Mock Start-Sleep { throw "Start-Sleep should not be called" }
        Mock Write-Host { throw "Write-Host should not be called" }

        $Settings = @{
            SecretVar = @{ Name = "gcesecretname"; Source = [GCESettingSource]::Secret }
        }

        $Result = Get-GCESettings -Settings $Settings

        Assert-MockCalled -Exactly -Times 1 Get-GCESecret
        Assert-MockCalled -Exactly -Times 0 Get-GCEInstanceMetadata
        Assert-MockCalled -Exactly -Times 0 Start-Sleep

        $Result.SecretVar | Should -Be $null
    }

    It "Returns secret with value if secret exists" {

        Mock Get-GCESecret -ParameterFilter { $Key -eq "gcesecretname"} { "gcesecretvalue" }
        Mock Get-GCESecret { throw "Invalid invocation of Get-GCESecret" }
        Mock Get-GCEInstanceMetadata { throw "Get-GCEInstanceMetadata should not be called" }
        Mock Start-Sleep { throw "Start-Sleep should not be called" }
        Mock Write-Host { throw "Write-Host should not be called" }

        $Settings = @{
            SecretVar = @{ Name = "gcesecretname"; Source = [GCESettingSource]::Secret }
        }

        $Result = Get-GCESettings -Settings $Settings

        Assert-MockCalled -Exactly -Times 1 Get-GCESecret
        Assert-MockCalled -Exactly -Times 0 Get-GCEInstanceMetadata
        Assert-MockCalled -Exactly -Times 0 Start-Sleep

        $Result.SecretVar | Should -Be "gcesecretvalue"
    }

    It "Returns null-valued instance metadata if value does not exist" {

        Mock Get-GCESecret { throw "Get-GCESecret should not be called" }
        Mock Get-GCEInstanceMetadata -ParameterFilter { $Key -eq "gceinstancemetadataname" } { $null }
        Mock Get-GCEInstanceMetadata { throw "Invalid invocation of Get-GCEInstanceMetadata" }
        Mock Start-Sleep { throw "Start-Sleep should not be called" }
        Mock Write-Host { throw "Write-Host should not be called" }

        $Settings = @{
            InstanceMetadataVar = @{ Name = "gceinstancemetadataname"; Source = [GCESettingSource]::InstanceMetadata }
        }

        $Result = Get-GCESettings -Settings $Settings

        Assert-MockCalled -Exactly -Times 0 Get-GCESecret
        Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceMetadata
        Assert-MockCalled -Exactly -Times 0 Start-Sleep

        $Result.InstanceMetadataVar | Should -Be $null
    }

    It "Returns value if instance metadata exists" {

        Mock Get-GCESecret { throw "Get-GCESecret should not be called" }
        Mock Get-GCEInstanceMetadata -ParameterFilter { $Key -eq "gceinstancemetadataname"} { "gceinstancemetadatavalue" }
        Mock Get-GCEInstanceMetadata { throw "Invalid invocation of Get-GCEInstanceMetadata" }
        Mock Start-Sleep { throw "Start-Sleep should not be called" }
        Mock Write-Host { throw "Write-Host should not be called" }

        $Settings = @{
            InstanceMetadataVar = @{ Name = "gceinstancemetadataname"; Source = [GCESettingSource]::InstanceMetadata }
        }

        $Result = Get-GCESettings -Settings $Settings

        Assert-MockCalled -Exactly -Times 0 Get-GCESecret
        Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceMetadata
        Assert-MockCalled -Exactly -Times 0 Start-Sleep

        $Result.InstanceMetadataVar | Should -Be "gceinstancemetadatavalue"
    }

    It "Passes binary flag to Get-GCESecret" {

        Mock Get-GCESecret -ParameterFilter { $Key -eq "gcesecretname1" } { $Binary | Should -Be $false; $null }
        Mock Get-GCESecret -ParameterFilter { $Key -eq "gcesecretname2" } { $Binary | Should -Be $false; $null }
        Mock Get-GCESecret -ParameterFilter { $Key -eq "gcesecretname3" } { $Binary | Should -Be $true; $null }
        Mock Get-GCESecret { throw "Invalid invocation of Get-GCESecret" }
        Mock Get-GCEInstanceMetadata { throw "Get-GCEInstanceMetadata should not be called" }
        Mock Start-Sleep { throw "Start-Sleep should not be called" }
        Mock Write-Host { throw "Write-Host should not be called" }

        $Settings = @{
            SecretVar1 = @{ Name = "gcesecretname1"; Source = [GCESettingSource]::Secret }
            SecretVar2 = @{ Name = "gcesecretname2"; Source = [GCESettingSource]::Secret; Binary = $false }
            SecretVar3 = @{ Name = "gcesecretname3"; Source = [GCESettingSource]::Secret; Binary = $true }
        }

        $Result = Get-GCESettings -Settings $Settings

        Assert-MockCalled -Exactly -Times 3 Get-GCESecret
        Assert-MockCalled -Exactly -Times 0 Start-Sleep

        $Result.SecretVar1 | Should -Be $null
        $Result.SecretVar2 | Should -Be $null
        $Result.SecretVar3 | Should -Be $null
    }

    It "Retries until all secrets are present, if asked to wait" {

		$script:LoopCount = 0

        Mock Get-GCESecret -ParameterFilter { $Key -eq "gcesecretname1" } { "value1" }
        Mock Get-GCESecret -ParameterFilter { $Key -eq "gcesecretname2" } { $script:LoopCount++; if ($script:LoopCount -lt 5) { $null } else { "value2" } }
        Mock Get-GCESecret -ParameterFilter { $Key -eq "gcesecretname3" } { "value3" }
        Mock Get-GCESecret { throw "Invalid invocation of Get-GCESecret" }
        Mock Get-GCEInstanceMetadata { throw "Get-GCEInstanceMetadata should not be called" }
        Mock Start-Sleep {}
#        Mock Write-Host { throw "Write-Host should not be called" }

        $Settings = @{
            SecretVar1 = @{ Name = "gcesecretname1"; Source = [GCESettingSource]::Secret; Binary = $false }
            SecretVar2 = @{ Name = "gcesecretname2"; Source = [GCESettingSource]::Secret; Binary = $false }
            SecretVar3 = @{ Name = "gcesecretname3"; Source = [GCESettingSource]::Secret; Binary = $false }
        }

        $Result = Get-GCESettings -Settings $Settings -Wait

        Assert-MockCalled -Exactly -Times (3 * 5) Get-GCESecret
        Assert-MockCalled -Exactly -Times (5 - 1) Start-Sleep

        $Result.SecretVar1 | Should -Be "value1"
        $Result.SecretVar2 | Should -Be "value2"
        $Result.SecretVar3 | Should -Be "value3"
    }

    It "Prints progress, if asked to do so" {

		$script:LoopCount = 0

        Mock Get-GCESecret -ParameterFilter { $Key -eq "gcesecretname1" } { "value1" }
        Mock Get-GCESecret -ParameterFilter { $Key -eq "gcesecretname2" } { $script:LoopCount++; if ($script:LoopCount -lt 5) { $null } else { "value2" } }
        Mock Get-GCESecret -ParameterFilter { $Key -eq "gcesecretname3" } { "value3" }
        Mock Get-GCESecret { throw "Invalid invocation of Get-GCESecret" }
        Mock Get-GCEInstanceMetadata { throw "Get-GCEInstanceMetadata should not be called" }
        Mock Start-Sleep {}
        Mock Write-Host {}

        $Settings = @{
            SecretVar1 = @{ Name = "gcesecretname1"; Source = [GCESettingSource]::Secret; Binary = $false }
            SecretVar2 = @{ Name = "gcesecretname2"; Source = [GCESettingSource]::Secret; Binary = $false }
            SecretVar3 = @{ Name = "gcesecretname3"; Source = [GCESettingSource]::Secret; Binary = $false }
        }

        $Result = Get-GCESettings -Settings $Settings -Wait -PrintProgress

        Assert-MockCalled -Exactly -Times (3 * 5) Get-GCESecret
        Assert-MockCalled -Exactly -Times (5 - 1) Start-Sleep
        Assert-MockCalled -Exactly -Times (4 * 5) Write-Host

        $Result.SecretVar1 | Should -Be "value1"
        $Result.SecretVar2 | Should -Be "value2"
        $Result.SecretVar3 | Should -Be "value3"
    }
}