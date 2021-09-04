. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESettings.ps1
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCEInstanceHostname.ps1
	. ${PSScriptRoot}\..\Run\Run-InboundAgent.ps1
}

Describe 'GCEService-InboundAgent' {

	BeforeEach {
		$AgentHostNameRef = "test-host.domain.internal"
		$AgentNameRef = "test-host"
		$RegionRef = "europe-west1"
		$JenkinsURLRef = "http://jenkins"
		$JenkinsSecretRef = "5678"
	
		$RequiredSettingsResponse = @{
			JenkinsUrl = $JenkinsURLRef
			JenkinsSecret = $JenkinsSecretRef
		}

		class ServiceMock {
			[void] WaitForStatus([string] $Status) {}
		}
	}

	It "Fails if Start-Transcript fails" {

		Mock Get-Date { "some date" }
		Mock Start-Transcript { throw "Start-Transcript failed" }
		Mock Stop-Transcript { throw "Stop-Transcript should not be called" }

		Mock Import-PowerShellDataFile { throw "Import-PowerShellDataFile should not be called" }
		Mock Resolve-Path { throw "Resolve-Path should not be called" }
		Mock Write-Host { throw "Write-Host should not be called" }
		Mock Get-GCEInstanceHostname { throw "Get-GCEInstanceHostname should not be called" }
		Mock Get-GCESettings { throw "Get-GCESettings should not be called" }
		Mock Get-Service { throw "Get-Service should not be called" }

		Mock Run-InboundAgent { throw "Run-InboundAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-InboundAgent.ps1 } |
			Should -Throw "Start-Transcript failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 0 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 0 Resolve-Path
		Assert-MockCalled -Exactly -Times 0 Write-Host
		Assert-MockCalled -Exactly -Times 0 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 0 Get-GCESettings
		Assert-MockCalled -Exactly -Times 0 Get-Service
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
		Mock Get-GCEInstanceHostname { throw "Get-GCEInstanceHostname should not be called" }
		Mock Get-GCESettings { throw "Get-GCESettings should not be called" }
		Mock Get-Service { throw "Get-Service should not be called" }

		Mock Run-InboundAgent { throw "Run-InboundAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-InboundAgent.ps1 } |
			Should -Throw "Import-PowerShellDataFile failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 0 Resolve-Path
		Assert-MockCalled -Exactly -Times 0 Write-Host
		Assert-MockCalled -Exactly -Times 0 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 0 Get-GCESettings
		Assert-MockCalled -Exactly -Times 0 Get-Service
		Assert-MockCalled -Exactly -Times 0 Run-InboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Succeeds if Run-InboundAgent succeeds; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("VMSettings.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Get-GCEInstanceHostname { $AgentHostNameRef }
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("JenkinsURL") } { $RequiredSettingsResponse }
		Mock Get-GCESettings { throw "Invalid invocation of Get-GCESettings" }
		Mock Get-Service { [ServiceMock]::new() }

		Mock Run-InboundAgent { }

		{ & ${PSScriptRoot}\GCEService-InboundAgent.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path -ParameterFilter { $Path.EndsWith("VMSettings.psd1") }
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 1 Get-GCESettings -ParameterFilter { $Settings.ContainsKey("JenkinsURL") }
		Assert-MockCalled -Exactly -Times 1 Get-GCESettings
		Assert-MockCalled -Exactly -Times 1 Get-Service
		Assert-MockCalled -Exactly -Times 1 Run-InboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Passes parameters properly between functions" {

		$VMSettings = Import-PowerShellDataFile -Path "${PSScriptRoot}\..\..\VMSettings.psd1" -ErrorAction Stop

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("VMSettings.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Get-GCEInstanceHostname { $AgentHostNameRef }
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("JenkinsURL") } {
			$Settings.ContainsKey("JenkinsURL") | Should -BeTrue
			$Settings.ContainsKey("JenkinsSecret") | Should -BeTrue
			$RequiredSettingsResponse 
		}
		Mock Get-GCESettings { throw "Invalid invocation of Get-GCESettings" }
		Mock Get-Service { [ServiceMock]::new() }

		Mock Run-InboundAgent {
			$JenkinsAgentFolder | Should -Be $VMSettings.JenkinsAgentFolder
			$JenkinsWorkspaceFolder | Should -Be $VMSettings.JenkinsWorkspaceFolder
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
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 1 Get-GCESettings
		Assert-MockCalled -Exactly -Times 1 Get-Service
		Assert-MockCalled -Exactly -Times 1 Run-InboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}
}