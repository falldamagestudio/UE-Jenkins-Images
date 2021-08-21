. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\..\SystemConfiguration\Resize-PartitionToMaxSize.ps1
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESettings.ps1
}

Describe 'GCEService-DockerSshAgent-Startup' {

	BeforeEach {
		$SshPublicKeyRef = "rsa-key abcd"

		$RequiredSettingsResponse = @{
			SshPublicKey = $SshPublicKeyRef
		}
	}

	It "Fails if Start-Transcript fails" {

		Mock Get-Date { "some date" }
		Mock Start-Transcript { throw "Start-Transcript failed" }
		Mock Stop-Transcript { throw "Stop-Transcript should not be called" }

		Mock Write-Host { throw "Write-Host should not be called" }
		Mock Resize-PartitionToMaxSize { throw "Resize-PartitionToMaxSize should not be called" }
		Mock Get-GCESettings { throw "Get-GCESettings should not be called" }
		Mock Set-Content { throw "Set-Content should not be called" }
		Mock Start-Service { throw "Start-Service should not be called" }
		Mock Get-Service { throw "Get-Service should not be called" }

		{ & ${PSScriptRoot}\GCEService-DockerSshAgent-Startup.ps1 } |
			Should -Throw "Start-Transcript failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 0 Write-Host
		Assert-MockCalled -Exactly -Times 0 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 0 Get-GCESettings
		Assert-MockCalled -Exactly -Times 0 Set-Content
		Assert-MockCalled -Exactly -Times 0 Start-Service
		Assert-MockCalled -Exactly -Times 0 Get-Service
		Assert-MockCalled -Exactly -Times 0 Stop-Transcript
	}

	It "Fails if Resize-PartitionToMaxSize fails; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { throw "Resize-PartitionToMaxSize failed" }
		Mock Get-GCESettings { throw "Get-GCESettings should not be called" }
		Mock Set-Content { throw "Set-Content should not be called" }
		Mock Start-Service { throw "Start-Service should not be called" }
		Mock Get-Service { throw "Get-Service should not be called" }

		{ & ${PSScriptRoot}\GCEService-DockerSshAgent-Startup.ps1 } |
			Should -Throw "Resize-PartitionToMaxSize failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 0 Get-GCESettings
		Assert-MockCalled -Exactly -Times 0 Set-Content
		Assert-MockCalled -Exactly -Times 0 Start-Service
		Assert-MockCalled -Exactly -Times 0 Get-Service
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Succeeds if Get-Service succeeds; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { }
		Mock Get-GCESettings { $RequiredSettingsResponse }
		Mock Set-Content { }
		Mock Start-Service { }
		Mock Get-Service { $obj = New-Object -TypeName PSObject; $obj | Add-Member -Type ScriptMethod -Name WaitForStatus -Value { param ( [string]$Status ) }; $obj }

		{ & ${PSScriptRoot}\GCEService-DockerSshAgent-Startup.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Get-GCESettings
		Assert-MockCalled -Exactly -Times 1 Set-Content
		Assert-MockCalled -Exactly -Times 1 Start-Service
		Assert-MockCalled -Exactly -Times 1 Get-Service
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Calls functions correctly and passes arguments appropriately" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { }
		Mock Get-GCESettings {
			$Settings.ContainsKey("SshPublicKey") | Should -BeTrue
			$RequiredSettingsResponse
		}
		Mock Set-Content {
			$Value | Should -Be $SshPublicKeyRef
		}
		Mock Start-Service {
			$Name | Should -Be "sshd"
		}
		Mock Get-Service {
			$Name | Should -Be "sshd"
			$obj = New-Object -TypeName PSObject
			$obj | Add-Member -Type ScriptMethod -Name WaitForStatus -Value { param ( [string]$Status ) }
			$obj
		}

		{ & ${PSScriptRoot}\GCEService-DockerSshAgent-Startup.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Get-GCESettings
		Assert-MockCalled -Exactly -Times 1 Set-Content
		Assert-MockCalled -Exactly -Times 1 Start-Service
		Assert-MockCalled -Exactly -Times 1 Get-Service
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}
}