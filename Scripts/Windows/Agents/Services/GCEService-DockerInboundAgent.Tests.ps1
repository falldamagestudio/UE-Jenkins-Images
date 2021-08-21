. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\..\SystemConfiguration\Resize-PartitionToMaxSize.ps1
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESecrets.ps1
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCEInstanceHostname.ps1
	. ${PSScriptRoot}\..\..\Applications\Deploy-PlasticClientConfig.ps1
	. ${PSScriptRoot}\..\..\Applications\Authenticate-DockerForGoogleArtifactRegistry.ps1
	. ${PSScriptRoot}\..\Run\Run-DockerInboundAgent.ps1
}

Describe 'GCEService-DockerInboundAgent' {

	BeforeEach {
		$AgentNameRef = "test-host"
		$RegionRef = "europe-west1"
		$JenkinsURLRef = "http://jenkins"
		$AgentImageURLRef = "${RegionRef}-docker.pkg.dev/someproject/somerepo/inbound-agent:latest"
		$AgentKeyFileRef = "1234"
		$JenkinsSecretRef = "5678"
		[byte[]] $PlasticConfigZipRef = 72, 101, 108, 108, 111 # "Hello"
	
		$RequiredSecretsResponse = @{
			JenkinsUrl = $JenkinsURLRef
			AgentKey = $AgentKeyFileRef
			AgentImageURL = $AgentImageURLRef
			JenkinsSecret = $JenkinsSecretRef
		}
	
		$OptionalSecretsResponse = @{
			PlasticConfigZip = $PlasticConfigZipRef
		}
	}

	It "Fails if Get-Date fails" {

		Mock Get-Date { throw "Get-Date failed" }
		Mock Start-Transcript { throw "Start-Transcript should not be called" }
		Mock Stop-Transcript { throw "Stop-Transcript should not be called" }

		Mock Import-PowerShellDataFile { throw "Import-PowerShellDataFile should not be called" }
		Mock Write-Host { throw "Write-Host should not be called" }
		Mock Resize-PartitionToMaxSize { throw "Resize-PartitionToMaxSize should not be called" }
		Mock Get-GCEInstanceHostname { throw "Get-GCEInstanceHostname should not be called" }
		Mock Get-GCESecrets { throw "Get-GCESecrets should not be called" }
		Mock Deploy-PlasticClientConfig { throw "Deploy-PlasticClientConfig should not be called" }
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry should not be called" }

		Mock Run-DockerInboundAgent { throw "Run-DockerInboundAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-DockerInboundAgent.ps1 } |
			Should -Throw "Get-Date failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 0 Start-Transcript
		Assert-MockCalled -Exactly -Times 0 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 0 Write-Host
		Assert-MockCalled -Exactly -Times 0 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 0 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 0 Get-GCESecrets
		Assert-MockCalled -Exactly -Times 0 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 0 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 0 Run-DockerInboundAgent
		Assert-MockCalled -Exactly -Times 0 Stop-Transcript
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
		Mock Get-GCESecrets { throw "Get-GCESecrets should not be called" }
		Mock Deploy-PlasticClientConfig { throw "Deploy-PlasticClientConfig should not be called" }
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry should not be called" }

		Mock Run-DockerInboundAgent { throw "Run-DockerInboundAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-DockerInboundAgent.ps1 } |
			Should -Throw "Start-Transcript failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 0 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 0 Resolve-Path
		Assert-MockCalled -Exactly -Times 0 Write-Host
		Assert-MockCalled -Exactly -Times 0 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 0 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 0 Get-GCESecrets
		Assert-MockCalled -Exactly -Times 0 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 0 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 0 Run-DockerInboundAgent
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
		Mock Get-GCESecrets { throw "Get-GCESecrets should not be called" }
		Mock Deploy-PlasticClientConfig { throw "Deploy-PlasticClientConfig should not be called" }
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry should not be called" }

		Mock Run-DockerInboundAgent { throw "Run-DockerInboundAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-DockerInboundAgent.ps1 } |
			Should -Throw "Import-PowerShellDataFile failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 0 Resolve-Path
		Assert-MockCalled -Exactly -Times 0 Write-Host
		Assert-MockCalled -Exactly -Times 0 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 0 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 0 Get-GCESecrets
		Assert-MockCalled -Exactly -Times 0 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 0 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 0 Run-DockerInboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Fails if Resize-PartitionToMaxSize fails; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { throw "Resize-PartitionToMaxSize failed" }
		Mock Get-GCEInstanceHostname { throw "Get-GCEInstanceHostname should not be called" }
		Mock Get-GCESecrets { throw "Get-GCESecrets should not be called" }
		Mock Deploy-PlasticClientConfig { throw "Deploy-PlasticClientConfig should not be called" }
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry should not be called" }

		Mock Run-DockerInboundAgent { throw "Run-DockerInboundAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-DockerInboundAgent.ps1 } |
			Should -Throw "Resize-PartitionToMaxSize failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") }
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 0 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 0 Get-GCESecrets
		Assert-MockCalled -Exactly -Times 0 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 0 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 0 Run-DockerInboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Fails if Get-GCEInstanceHostName fails; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { }
		Mock Get-GCEInstanceHostname { throw "Get-GCEInstanceHostname failed" }
		Mock Get-GCESecrets { throw "Get-GCESecrets should not be called" }
		Mock Deploy-PlasticClientConfig { throw "Deploy-PlasticClientConfig should not be called" }
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry should not be called" }

		Mock Run-DockerInboundAgent { throw "Run-DockerInboundAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-DockerInboundAgent.ps1 } |
			Should -Throw "Get-GCEInstanceHostname failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") }
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 0 Get-GCESecrets
		Assert-MockCalled -Exactly -Times 0 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 0 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 0 Run-DockerInboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Fails if Get-GCESecrets for required secrets fails; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { }
		Mock Get-GCEInstanceHostname { "host" }
		Mock Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("JenkinsURL") } { throw "Get-GCESecrets for required secrets failed" }
		Mock Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("PlasticConfigZip") } { throw "Get-GCESecrets for optional secrets should not be called" }
		Mock Get-GCESecrets { throw "Invalid invocation of Get-GCESecrets" }
		Mock Deploy-PlasticClientConfig { throw "Deploy-PlasticClientConfig should not be called" }
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry should not be called" }

		Mock Run-DockerInboundAgent { throw "Run-DockerInboundAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-DockerInboundAgent.ps1 } |
			Should -Throw "Get-GCESecrets for required secrets failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") }
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 1 Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("JenkinsURL") }
		Assert-MockCalled -Exactly -Times 0 Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("PlasticConfigZip") }
		Assert-MockCalled -Exactly -Times 1 Get-GCESecrets
		Assert-MockCalled -Exactly -Times 0 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 0 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 0 Run-DockerInboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Fails if Get-GCESecrets for required secrets fails; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { }
		Mock Get-GCEInstanceHostname { "host" }
		Mock Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("JenkinsURL") } { $RequiredSecretsResponse }
		Mock Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("PlasticConfigZip") } { throw "Get-GCESecrets for optional secrets failed" }
		Mock Get-GCESecrets { throw "Invalid invocation of Get-GCESecrets" }
		Mock Deploy-PlasticClientConfig { throw "Deploy-PlasticClientConfig should not be called" }
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry should not be called" }

		Mock Run-DockerInboundAgent { throw "Run-DockerInboundAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-DockerInboundAgent.ps1 } |
			Should -Throw "Get-GCESecrets for optional secrets failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") }
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 1 Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("JenkinsURL") }
		Assert-MockCalled -Exactly -Times 1 Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("PlasticConfigZip") }
		Assert-MockCalled -Exactly -Times 2 Get-GCESecrets
		Assert-MockCalled -Exactly -Times 0 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 0 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 0 Run-DockerInboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Fails if Deploy-PlasticClientConfig fails; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { }
		Mock Get-GCEInstanceHostname { "host" }
		Mock Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("JenkinsURL") } { $RequiredSecretsResponse }
		Mock Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("PlasticConfigZip") } { $OptionalSecretsResponse }
		Mock Get-GCESecrets { throw "Invalid invocation of Get-GCESecrets" }
		Mock Deploy-PlasticClientConfig { throw "Deploy-PlasticClientConfig failed" }
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry should not be called" }

		Mock Run-DockerInboundAgent { throw "Run-DockerInboundAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-DockerInboundAgent.ps1 } |
			Should -Throw "Deploy-PlasticClientConfig failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") }
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 1 Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("JenkinsURL") }
		Assert-MockCalled -Exactly -Times 1 Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("PlasticConfigZip") }
		Assert-MockCalled -Exactly -Times 2 Get-GCESecrets
		Assert-MockCalled -Exactly -Times 1 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 0 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 0 Run-DockerInboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Fails if Authenticate-DockerForGoogleArtifactRegistry fails; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { }
		Mock Get-GCEInstanceHostname { "host" }
		Mock Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("JenkinsURL") } { $RequiredSecretsResponse }
		Mock Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("PlasticConfigZip") } { $OptionalSecretsResponse }
		Mock Get-GCESecrets { throw "Invalid invocation of Get-GCESecrets" }
		Mock Deploy-PlasticClientConfig { }
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry failed" }

		Mock Run-DockerInboundAgent { throw "Run-DockerInboundAgent should not be called" }

		{ & ${PSScriptRoot}\GCEService-DockerInboundAgent.ps1 } |
			Should -Throw "Authenticate-DockerForGoogleArtifactRegistry failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") }
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 1 Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("JenkinsURL") }
		Assert-MockCalled -Exactly -Times 1 Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("PlasticConfigZip") }
		Assert-MockCalled -Exactly -Times 2 Get-GCESecrets
		Assert-MockCalled -Exactly -Times 1 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 1 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 0 Run-DockerInboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Fails if Run-DockerInboundAgent fails; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { }
		Mock Get-GCEInstanceHostname { "host" }
		Mock Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("JenkinsURL") } { $RequiredSecretsResponse }
		Mock Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("PlasticConfigZip") } { $OptionalSecretsResponse }
		Mock Get-GCESecrets { throw "Invalid invocation of Get-GCESecrets" }
		Mock Deploy-PlasticClientConfig { }
		Mock Authenticate-DockerForGoogleArtifactRegistry { }

		Mock Run-DockerInboundAgent { throw "Run-DockerInboundAgent failed" }

		{ & ${PSScriptRoot}\GCEService-DockerInboundAgent.ps1 } |
			Should -Throw "Run-DockerInboundAgent failed"

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") }
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 1 Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("JenkinsURL") }
		Assert-MockCalled -Exactly -Times 1 Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("PlasticConfigZip") }
		Assert-MockCalled -Exactly -Times 2 Get-GCESecrets
		Assert-MockCalled -Exactly -Times 1 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 1 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 1 Run-DockerInboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Succeeds if Run-DockerInboundAgent succeeds; stops transcript" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { }
		Mock Get-GCEInstanceHostname { "host" }
		Mock Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("JenkinsURL") } { $RequiredSecretsResponse }
		Mock Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("PlasticConfigZip") } { $OptionalSecretsResponse }
		Mock Get-GCESecrets { throw "Invalid invocation of Get-GCESecrets" }
		Mock Deploy-PlasticClientConfig { }
		Mock Authenticate-DockerForGoogleArtifactRegistry { }

		Mock Run-DockerInboundAgent { }

		{ & ${PSScriptRoot}\GCEService-DockerInboundAgent.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") }
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 1 Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("JenkinsURL") }
		Assert-MockCalled -Exactly -Times 1 Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("PlasticConfigZip") }
		Assert-MockCalled -Exactly -Times 2 Get-GCESecrets
		Assert-MockCalled -Exactly -Times 1 Deploy-PlasticClientConfig
		Assert-MockCalled -Exactly -Times 1 Authenticate-DockerForGoogleArtifactRegistry
		Assert-MockCalled -Exactly -Times 1 Run-DockerInboundAgent
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}

	It "Passes parameters properly between functions" {

		Mock Start-Transcript { }
		Mock Get-Date { "some date" }
		Mock Stop-Transcript { }

		Mock Import-PowerShellDataFile { & (Get-Command Import-PowerShellDataFile -CommandType Function) -Path $Path }
		Mock Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") } { & (Get-Command Resolve-Path -CommandType Cmdlet) -Path $Path }
		Mock Resolve-Path { throw "Invalid invocation of Resolve-Path" }
		Mock Write-Host { }
		Mock Resize-PartitionToMaxSize { }
		Mock Get-GCEInstanceHostname { "host" }
		Mock Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("JenkinsURL") } { $RequiredSecretsResponse }
		Mock Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("PlasticConfigZip") } { $OptionalSecretsResponse }
		Mock Get-GCESecrets { throw "Invalid invocation of Get-GCESecrets" }
		Mock Deploy-PlasticClientConfig { }
		Mock Authenticate-DockerForGoogleArtifactRegistry { }

		Mock Run-DockerInboundAgent { }

		{ & ${PSScriptRoot}\GCEService-DockerInboundAgent.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Get-Date
		Assert-MockCalled -Exactly -Times 1 Start-Transcript
		Assert-MockCalled -Exactly -Times 1 Import-PowerShellDataFile
		Assert-MockCalled -Exactly -Times 1 Resolve-Path -ParameterFilter { $Path.EndsWith("DefaultFolders.psd1") }
		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Resize-PartitionToMaxSize
		Assert-MockCalled -Exactly -Times 1 Get-GCEInstanceHostname
		Assert-MockCalled -Exactly -Times 1 Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("JenkinsURL") -and $Secrets.ContainsKey("AgentKey") -and $Secrets.ContainsKey("AgentImageURL") -and $Secrets.ContainsKey("JenkinsSecret") }
		Assert-MockCalled -Exactly -Times 1 Get-GCESecrets -ParameterFilter { $Secrets.ContainsKey("PlasticConfigZip") }
		Assert-MockCalled -Exactly -Times 2 Get-GCESecrets
		Assert-MockCalled -Exactly -Times 1 Deploy-PlasticClientConfig -ParameterFilter { !(Compare-Object -ReferenceObject $PlasticConfigZipRef -DifferenceObject $ZipContent) }
		Assert-MockCalled -Exactly -Times 1 Authenticate-DockerForGoogleArtifactRegistry -ParameterFilter { ($AgentKey -eq $AgentKeyFileRef) -and ($Region -eq $RegionRef) }
		Assert-MockCalled -Exactly -Times 1 Run-DockerInboundAgent -ParameterFilter { ($JenkinsUrl -eq $JenkinsUrlRef) -and ($JenkinsSecret -eq $JenkinsSecretRef) -and ($AgentImageURL -eq $AgentImageURLRef)}
		Assert-MockCalled -Exactly -Times 1 Stop-Transcript
	}
}