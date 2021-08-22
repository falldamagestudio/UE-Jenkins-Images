. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\..\SystemConfiguration\Resize-PartitionToMaxSize.ps1
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESettings.ps1
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCEInstanceHostname.ps1
	. ${PSScriptRoot}\..\..\Applications\Deploy-PlasticClientConfig.ps1
	. ${PSScriptRoot}\..\Run\Run-InboundAgent.ps1
}

Describe 'GCEService-InboundAgent' {

	BeforeEach {
		$AgentHostNameRef = "test-host.domain.internal"
		$AgentNameRef = "test-host"
		$RegionRef = "europe-west1"
		$JenkinsURLRef = "http://jenkins"
		$JenkinsSecretRef = "5678"
		[byte[]] $PlasticConfigZipRef = 72, 101, 108, 108, 111 # "Hello"
	
		$RequiredSettingsResponse = @{
			JenkinsUrl = $JenkinsURLRef
			JenkinsSecret = $JenkinsSecretRef
		}
	
		$OptionalSettingsResponse = @{
			PlasticConfigZip = $PlasticConfigZipRef
		}
	}

	It "Fails if Start-Transcript fails" {

		Mock Get-Date { "some date" }
		Mock Start-Transcript { throw "Start-Transcript failed" }
		Mock Stop-Transcript { throw "Stop-Transcript should not be called" }

		Mock Import-PowerShellDataFile { throw "Import-PowerShellDataFile should not be called" }
		Mock Resolve-Path { throw "Resolve-Path should not be called" }
		Mock Write-Host { throw "Write-Host should not be called" }
		Mock Resize-PartitionToMaxSize { throw "Resize-PartitionToMaxSize should not be called" }
		Mock Get-GCEInstanceHostname { throw "Get-GCEInstanceHostname should not be called" }
		Mock Get-GCESettings { throw "Get-GCESettings should not be called" }
		Mock Deploy-PlasticClientConfig { throw "Deploy-PlasticClientConfig should not be called" }

		Mock Run-InboundAgent { throw "Run-InboundAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-InboundAgent.ps1 } |
			Should -Throw "Start-Transcript failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 0 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 0 Resolve-Path
		Assert-MockCalled -Exactly -Times 0 Write-Host
		Assert-MockCalled -Exactly -Times 0 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 0 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 0 Get-GCESettings
		Assert-MockCalled -Exactly -Times 0 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 0 Run-InboundAgent
		Assert-MockCalled -Exactly -Times 0 Stop-Transcript
	}

	It "Fails if Import-PowerShellDataFile fails; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { throw "Import-PowerShellDataFile failed" }
		Mock Resolve-Path { throw "Resolve-Path should not be called" }
		Mock Write-Host { throw "Write-Host should not be called" }
		Mock Resize-PartitionToMaxSize { throw "Resize-PartitionToMaxSize should not be called" }
		Mock Get-GCEInstanceHostname { throw "Get-GCEInstanceHostname should not be called" }
		Mock Get-GCESettings { throw "Get-GCESettings should not be called" }
		Mock Deploy-PlasticClientConfig { throw "Deploy-PlasticClientConfig should not be called" }

		Mock Run-InboundAgent { throw "Run-InboundAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-InboundAgent.ps1 } |
			Should -Throw "Import-PowerShellDataFile failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 0 Resolve-Path
		Assert-MockCalled -Exactly -Times 0 Write-Host
		Assert-MockCalled -Exactly -Times 0 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 0 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 0 Get-GCESettings
		Assert-MockCalled -Exactly -Times 0 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 0 Run-InboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Succeeds if Run-InboundAgent succeeds; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultBuildStepSettings.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { }
		Mock Get-GCEInstanceHostname { $AgentHostNameRef }
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("JenkinsURL") } { $RequiredSettingsResponse }
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("PlasticConfigZip") } { $OptionalSettingsResponse }
		Mock Get-GCESettings { throw "Invalid invocation of Get-GCESettings" }
		Mock Deploy-PlasticClientConfig { }

		Mock Run-InboundAgent { }

		{ & ${PSScriptRoot}\GCEService-InboundAgent.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultBuildStepSettings.psd1") }
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 1 Get-GCESettings -ParameterFilter { $Settings.ContainsKey("JenkinsURL") }
		Assert-MockCalled -Exactly -Times 1 Get-GCESettings -ParameterFilter { $Settings.ContainsKey("PlasticConfigZip") }
		Assert-MockCalled -Exactly -Times 2 Get-GCESettings
		Assert-MockCalled -Exactly -Times 1 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 1 Run-InboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Skips plastic configuration if the plastic config zip setting is not available" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultBuildStepSettings.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { }
		Mock Get-GCEInstanceHostname { $AgentHostNameRef }
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("JenkinsURL") } { $RequiredSettingsResponse }
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("PlasticConfigZip") } { @{ PlasticConfigZip = $null } }
		Mock Get-GCESettings { throw "Invalid invocation of Get-GCESettings" }
		Mock Deploy-PlasticClientConfig { throw "Deploy-PlasticClientConfig should not be called" }

		Mock Run-InboundAgent { }

		{ & ${PSScriptRoot}\GCEService-InboundAgent.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultBuildStepSettings.psd1") }
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 1 Get-GCESettings -ParameterFilter { $Settings.ContainsKey("JenkinsURL") }
		Assert-MockCalled -Exactly -Times 1 Get-GCESettings -ParameterFilter { $Settings.ContainsKey("PlasticConfigZip") }
		Assert-MockCalled -Exactly -Times 2 Get-GCESettings
		Assert-MockCalled -Exactly -Times 0 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 1 Run-InboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Passes parameters properly between functions" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultBuildStepSettings.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { }
		Mock Get-GCEInstanceHostname { $AgentHostNameRef }
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("JenkinsURL") } {
			$Settings.ContainsKey("JenkinsURL") | Should -BeTrue
			$Settings.ContainsKey("JenkinsSecret") | Should -BeTrue
			$RequiredSettingsResponse 
		}
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("PlasticConfigZip") } { $OptionalSettingsResponse }
		Mock Get-GCESettings { throw "Invalid invocation of Get-GCESettings" }
		Mock Deploy-PlasticClientConfig {
			(Compare-Object -ReferenceObject $PlasticConfigZipRef -DifferenceObject $ZipContent) | Should -Be $null
		}

		Mock Run-InboundAgent {
			$JenkinsUrl | Should -Be $JenkinsUrlRef
			$JenkinsSecret | Should -Be $JenkinsSecretRef
			$AgentName | Should -Be $AgentNameRef
		}

		{ & ${PSScriptRoot}\GCEService-InboundAgent.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 2 Get-GCESettings
		Assert-MockCalled -Exactly -Times 1 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 1 Run-InboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}
}