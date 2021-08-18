. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\..\SystemConfiguration\Resize-PartitionToMaxSize.ps1
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESecret.ps1
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCEInstanceHostname.ps1
	. ${PSScriptRoot}\..\..\Applications\Authenticate-DockerForGoogleArtifactRegistry.ps1
	. ${PSScriptRoot}\..\Run\Run-DockerInboundAgent.ps1
}

Describe 'GCEService-DockerInboundAgent' {

	It "Retries settings fetch until parameters are available" {

		$AgentNameRef = "test-host"
		$RegionRef = "europe-west1"
		$JenkinsURLRef = "http://jenkins"
		$AgentImageURLRef = "${RegionRef}-docker.pkg.dev/someproject/somerepo/inbound-agent:latest"
		$AgentKeyFileRef = "1234"
		$JenkinsSecretRef = "5678"
		$PlasticConfigZipRef = @(72, 101, 108, 108, 111) # "Hello"

		$script:LoopCount = 0
		$script:SleepCount = 0

		Mock Start-Transcript { }
		Mock Resolve-Path { "invalid path" }
		Mock Get-Date { "invalid date" }
		Mock Stop-Transcript { }

		Mock Write-Host { }

		Mock Resize-PartitionToMaxSize { }

		Mock Get-GCEInstanceHostname { "${AgentNameRef}.c.testproject.internal" }

		Mock Get-GCESecret -ParameterFilter { $Key -eq "jenkins-url" } { $JenkinsURLRef }
		Mock Get-GCESecret -ParameterFilter { $Key -eq "agent-key-file" } { $AgentKeyFileRef }
		Mock Get-GCESecret -ParameterFilter { $Key -eq "inbound-agent-image-url-windows" } { $AgentImageURLRef }
		Mock Get-GCESecret -ParameterFilter { $Key -eq "inbound-agent-secret-${AgentNameRef}" } { if ($script:LoopCount -lt 3) { $script:LoopCount++; $null } else { $JenkinsSecretRef } }
		Mock Get-GCESecret -ParameterFilter { $Key -eq "plastic-config-zip" } { $PlasticConfigZipRef }
		Mock Get-GCESecret { throw "Invalid invocation of Get-GCESecret" }

		Mock Expand-Archive { }

		Mock Authenticate-DockerForGoogleArtifactRegistry -ParameterFilter { ($AgentKey -eq $AgentKeyFileRef) -and ($Region -eq $RegionRef) } {}
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Invalid invocation of Authenticate-DockerForGoogleArtifactRegistry" }

		Mock Run-DockerInboundAgent -ParameterFilter { ($JenkinsURL -eq $JenkinsURLRef) -and ($JenkinsSecret -eq $JenkinsSecretRef) -and ($AgentImageURL -eq $AgentImageURLRef) -and ($AgentName -eq $AgentNameRef) } { }
		Mock Run-DockerInboundAgent { throw "Invalid invocation of Run-DockerInboundAgent" }

		Mock Start-Sleep { if ($script:SleepCount -lt 10) { $script:SleepCount++ } else { throw "Infinite loop detected when waiting for GCE secrets to be set" } }

		{ & ${PSScriptRoot}\GCEService-DockerInboundAgent.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "jenkins-url" }
		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "agent-key-file" }
		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "inbound-agent-image-url-windows" }
		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "inbound-agent-secret-${AgentNameRef}" }
		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "plastic-config-zip" }

		Assert-MockCalled -Times 2 Start-Sleep

		Assert-MockCalled -Times 1 Expand-Archive

		Assert-MockCalled -Times 1 Authenticate-DockerForGoogleArtifactRegistry

		Assert-MockCalled -Times 1 Run-DockerInboundAgent
	}
}