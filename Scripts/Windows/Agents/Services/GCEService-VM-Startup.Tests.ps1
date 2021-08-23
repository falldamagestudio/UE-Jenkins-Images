. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESettings.ps1
	. ${PSScriptRoot}\..\..\Applications\Deploy-PlasticClientConfig.ps1
	. ${PSScriptRoot}\..\..\SystemConfiguration\Resize-PartitionToMaxSize.ps1
}

Describe 'GCEService-VM-Startup' {

	BeforeEach {
		$SshPublicKeyRef = "rsa-key abcd"
		[byte[]] $PlasticConfigZipRef = 72, 101, 108, 108, 111 # "Hello"

		$RequiredSettingsResponse = @{
			SshPublicKey = $SshPublicKeyRef
		}

		$OptionalSettingsResponse = @{
			PlasticConfigZip = $PlasticConfigZipRef
		}
	}

	It "Fails if Start-Transcript fails" {

		Mock Get-Date { "some date" }
		Mock Start-Transcript { throw "Start-Transcript failed" }
		Mock Stop-Transcript { throw "Stop-Transcript should not be called" }

		Mock Write-Host { throw "Write-Host should not be called" }
		Mock Get-GCESettings { throw "Get-GCESettings should not be called" }
		Mock Set-Content { throw "Set-Content should not be called" }
		Mock Deploy-PlasticClientConfig { throw "Deploy-PlasticClientConfig should not be called" }
		Mock Start-Service { throw "Start-Service should not be called" }
		Mock Resize-PartitionToMaxSize { throw "Resize-PartitionToMaxSize should not be called" }
		Mock Stop-Service { throw "Stop-Service should not be called" }

		{ & ${PSScriptRoot}\GCEService-VM-Startup.ps1 } |
			Should -Throw "Start-Transcript failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 0 Write-Host
		Assert-MockCalled -Exactly -Times 0 Get-GCESettings
		Assert-MockCalled -Exactly -Times 0 Set-Content
		Assert-MockCalled -Exactly -Times 0 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 0 Start-Service
		Assert-MockCalled -Exactly -Times 0 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 0 Stop-Service
		Assert-MockCalled -Exactly -Times 0 Stop-Transcript
	}

	It "Fails if Get-GCESettings fails; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Write-Host { }
		Mock Get-GCESettings { throw "Get-GCESettings failed" }
		Mock Set-Content { throw "Set-Content should not be called" }
		Mock Deploy-PlasticClientConfig { throw "Deploy-PlasticClientConfig should not be called" }
		Mock Start-Service { throw "Start-Service should not be called" }
		Mock Resize-PartitionToMaxSize { throw "Resize-PartitionToMaxSize should not be called" }
		Mock Stop-Service { throw "Stop-Service should not be called" }

		{ & ${PSScriptRoot}\GCEService-VM-Startup.ps1 } |
			Should -Throw "Get-GCESettings failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Get-GCESettings
		Assert-MockCalled -Exactly -Times 0 Set-Content
		Assert-MockCalled -Exactly -Times 0 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 0 Start-Service
		Assert-MockCalled -Exactly -Times 0 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 0 Stop-Service
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Succeeds if all steps succeed; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Write-Host { }
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("SshPublicKey") } { $RequiredSettingsResponse }
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("PlasticConfigZip") } { $OptionalSettingsResponse }
		Mock Get-GCESettings { throw "Invalid invocation of Get-GCESettings" }
		Mock Set-Content { }
		Mock Start-Service { }
		Mock Deploy-PlasticClientConfig { }
		Mock Stop-Service { }

		Mock Resize-PartitionToMaxSize { }

		{ & ${PSScriptRoot}\GCEService-VM-Startup.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 2 Get-GCESettings
		Assert-MockCalled -Exactly -Times 1 Set-Content
		Assert-MockCalled -Exactly -Times 1 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 1 Start-Service
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Stop-Service
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Calls functions correctly and passes arguments appropriately" {

		$DefaultFolders = Import-PowerShellDataFile -Path "${PSScriptRoot}\..\..\BuildSteps\DefaultBuildStepSettings.psd1" -ErrorAction Stop

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Write-Host { }
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("SshPublicKey") } { $RequiredSettingsResponse }
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("PlasticConfigZip") } { $OptionalSettingsResponse }
		Mock Set-Content {
			$Value | Should -Be $SshPublicKeyRef
		}
		Mock Deploy-PlasticClientConfig {
			(Compare-Object -ReferenceObject $PlasticConfigZipRef -DifferenceObject $ZipContent) | Should -Be $null
			$ConfigFolder | Should -Be $DefaultFolders.PlasticConfigFolder
		}
		Mock Start-Service {
			$Name | Should -Be "sshd"
		}

		Mock Resize-PartitionToMaxSize { }

		Mock Stop-Service {
			$Name | Should -Be $DefaultFolders.JenkinsVMStartupServiceName
		}

		{ & ${PSScriptRoot}\GCEService-VM-Startup.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 2 Get-GCESettings
		Assert-MockCalled -Exactly -Times 1 Set-Content
		Assert-MockCalled -Exactly -Times 1 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 1 Start-Service
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Stop-Service
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}
}