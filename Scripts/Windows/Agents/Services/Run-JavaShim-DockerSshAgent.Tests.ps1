
. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESettings.ps1
	. ${PSScriptRoot}\..\Run\Run-DockerSshAgent.ps1
	. ${PSScriptRoot}\..\..\Applications\Authenticate-DockerForGoogleArtifactRegistry.ps1
}

Describe 'Run-JavaShim-DockerSshAgent' {

	BeforeEach {
		$AgentHostNameRef = "test-host.domain.internal"
		$AgentNameRef = "test-host"
		$RegionRef = "europe-west1"
		$AgentImageURLRef = "${RegionRef}-docker.pkg.dev/someproject/somerepo/inbound-agent:latest"
		$AgentKeyFileRef = "1234"
	
		$RequiredSettingsResponse = @{
			AgentKey = $AgentKeyFileRef
			AgentImageURL = $AgentImageURLRef
		}
	}

	It "Succeeds when launched with -fullversion" {

		Mock Start-Transcript { }
		Mock Get-Date { "invalid date" }
		Mock Write-Host { }
		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Get-GCESettings { throw "Get-GCESettings should not be called" }
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry should not be called" }
		Mock Copy-Item { throw "Copy-Item should not be called" }
		Mock Run-DockerSshAgent { throw "Run-DockerSshAgent should not be called" }
		Mock Stop-Transcript { }

		{ & ${PSScriptRoot}\Run-JavaShim-DockerSshAgent.ps1 -fullversion } |
			Should -Not -Throw
	}

	It "Fails when launched without any options" {

		Mock Start-Transcript { }
		Mock Get-Date { "invalid date" }
		Mock Write-Host { }
		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Get-GCESettings { throw "Get-GCESettings should not be called" }
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry should not be called" }
		Mock Copy-Item { throw "Copy-Item should not be called" }
		Mock Run-DockerSshAgent { throw "Run-DockerSshAgent should not be called" }
		Mock Stop-Transcript { }

		{ & ${PSScriptRoot}\Run-JavaShim-DockerSshAgent.ps1 } |
			Should -Throw
	}

	It "Succeeds when launched with -jar <jarfile>" {

		Mock Start-Transcript { }
		Mock Get-Date { "invalid date" }
		Mock Write-Host { }
		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultBuildStepSettings.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("AgentKey") } {
			$Settings.ContainsKey("AgentKey") | Should -BeTrue
			$Settings.ContainsKey("AgentImageURL") | Should -BeTrue
			$RequiredSettingsResponse 
		}
		Mock Get-GCESettings { throw "Invalid invocation of Get-GCESettings" }
		Mock Authenticate-DockerForGoogleArtifactRegistry {
			$AgentKey | Should -Be $AgentKeyFileRef
			$Region | Should -Be $RegionRef
		}
		Mock Copy-Item { }
		Mock Run-DockerSshAgent {
			$AgentImageURL | Should -Be $AgentImageURLRef
		}
		Mock Stop-Transcript { }

		{ & ${PSScriptRoot}\Run-JavaShim-DockerSshAgent.ps1 -jar "C:\AgentJarDownloadLocation\agent.jar" } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Get-GCESettings
		Assert-MockCalled -Exactly -Times 1 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 1 Copy-Item
		Assert-MockCalled -Exactly -Times 1 Run-DockerSshAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}
}