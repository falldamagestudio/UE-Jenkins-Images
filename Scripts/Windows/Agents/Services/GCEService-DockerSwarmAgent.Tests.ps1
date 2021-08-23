. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESettings.ps1
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCEInstanceHostname.ps1
	. ${PSScriptRoot}\..\..\Applications\Authenticate-DockerForGoogleArtifactRegistry.ps1
	. ${PSScriptRoot}\..\Run\Run-DockerSwarmAgent.ps1
}

Describe 'GCEService-DockerSwarmAgent' {

	BeforeEach {
		$AgentHostNameRef = "test-host.domain.internal"
		$AgentNameRef = "test-host"
		$RegionRef = "europe-west1"
		$JenkinsURLRef = "http://jenkins"
		$AgentUsernameRef = "admin@example.com"
		$AgentAPITokenRef = "5678"
		$AgentImageURLRef = "${RegionRef}-docker.pkg.dev/someproject/somerepo/inbound-agent:latest"
		$AgentKeyFileRef = "1234"
		$LabelsRef = "lab1 lab2"
	
		$RequiredSettingsResponse = @{
			JenkinsUrl = $JenkinsURLRef
			AgentKey = $AgentKeyFileRef
			AgentUsername = $AgentUsernameRef
			AgentAPIToken = $AgentAPITokenRef
			AgentImageURL = $AgentImageURLRef
			Labels = $LabelsRef
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
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry should not be called" }
		Mock Get-Service { throw "Get-Service should not be called" }

		Mock Run-DockerSwarmAgent { throw "Run-DockerSwarmAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-DockerSwarmAgent.ps1 } |
			Should -Throw "Start-Transcript failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 0 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 0 Resolve-Path
		Assert-MockCalled -Exactly -Times 0 Write-Host
		Assert-MockCalled -Exactly -Times 0 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 0 Get-GCESettings
		Assert-MockCalled -Exactly -Times 0 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 0 Get-Service
		Assert-MockCalled -Exactly -Times 0 Run-DockerSwarmAgent
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
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry should not be called" }
		Mock Get-Service { throw "Get-Service should not be called" }

		Mock Run-DockerSwarmAgent { throw "Run-DockerSwarmAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-DockerSwarmAgent.ps1 } |
			Should -Throw "Import-PowerShellDataFile failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 0 Resolve-Path
		Assert-MockCalled -Exactly -Times 0 Write-Host
		Assert-MockCalled -Exactly -Times 0 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 0 Get-GCESettings
		Assert-MockCalled -Exactly -Times 0 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 0 Get-Service
		Assert-MockCalled -Exactly -Times 0 Run-DockerSwarmAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Succeeds if Run-DockerSwarmAgent succeeds; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultBuildStepSettings.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Get-GCEInstanceHostname { $AgentHostNameRef }
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("JenkinsURL") } { $RequiredSettingsResponse }
		Mock Get-GCESettings { throw "Invalid invocation of Get-GCESettings" }
		Mock Authenticate-DockerForGoogleArtifactRegistry { }
		Mock Get-Service { [ServiceMock]::new() }

		Mock Run-DockerSwarmAgent { }

		{ & ${PSScriptRoot}\GCEService-DockerSwarmAgent.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultBuildStepSettings.psd1") }
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 1 Get-GCESettings -ParameterFilter { $Settings.ContainsKey("JenkinsURL") }
		Assert-MockCalled -Exactly -Times 1 Get-GCESettings
		Assert-MockCalled -Exactly -Times 1 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 1 Get-Service
		Assert-MockCalled -Exactly -Times 1 Run-DockerSwarmAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Passes parameters properly between functions" {

		$DefaultFolders = Import-PowerShellDataFile -Path "${PSScriptRoot}\..\..\BuildSteps\DefaultBuildStepSettings.psd1" -ErrorAction Stop

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultBuildStepSettings.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Get-GCEInstanceHostname { $AgentHostNameRef }
		Mock Get-GCESettings -ParameterFilter { $Settings.ContainsKey("JenkinsURL") } {
			$Settings.ContainsKey("JenkinsURL") | Should -BeTrue
			$Settings.ContainsKey("AgentKey") | Should -BeTrue
			$Settings.ContainsKey("AgentUsername") | Should -BeTrue
			$Settings.ContainsKey("AgentAPIToken") | Should -BeTrue
			$Settings.ContainsKey("AgentImageURL") | Should -BeTrue
			$Settings.ContainsKey("Labels") | Should -BeTrue
			$RequiredSettingsResponse 
		}
		Mock Get-GCESettings { throw "Invalid invocation of Get-GCESettings" }
		Mock Authenticate-DockerForGoogleArtifactRegistry {
			$AgentKey | Should -Be $AgentKeyFileRef
			$Region | Should -Be $RegionRef
		}
		Mock Get-Service { [ServiceMock]::new() }

		Mock Run-DockerSwarmAgent {
			$JenkinsAgentFolder | Should -Be $DefaultFolders.JenkinsAgentFolder
			$JenkinsWorkspaceFolder | Should -Be $DefaultFolders.JenkinsWorkspaceFolder
			$PlasticConfigFolder | Should -Be $DefaultFolders.PlasticConfigFolder
			$JenkinsUrl | Should -Be $JenkinsUrlRef
			$AgentUsername | Should -Be $AgentUsernameRef
			$AgentAPIToken | Should -Be $AgentAPITokenRef
			$AgentImageURL | Should -Be $AgentImageURLRef
			$Labels | Should -Be $LabelsRef
			$AgentName | Should -Be $AgentNameRef
		}

		{ & ${PSScriptRoot}\GCEService-DockerSwarmAgent.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 1 Get-GCESettings
		Assert-MockCalled -Exactly -Times 1 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 1 Get-Service
		Assert-MockCalled -Exactly -Times 1 Run-DockerSwarmAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}
}