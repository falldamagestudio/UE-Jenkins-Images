. ${PSScriptRoot}\..\Tools\Scripts\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\Tools\Scripts\Get-GCEInstanceMetadata.ps1
	. ${PSScriptRoot}\..\Tools\Scripts\Get-GCESecret.ps1
	. ${PSScriptRoot}\..\Tools\Scripts\Authenticate-DockerForGoogleArtifactRegistry.ps1
	. ${PSScriptRoot}\..\Tools\Scripts\Run-JenkinsAgent.ps1
}

Describe 'GCEService' {

	It "Retries settings fetch until parameters are available" {

		$AgentNameRef = "test-host"
		$RegionRef = "europe-west1"
		$JenkinsURLRef = "http://jenkins"
		$AgentImageURLRef = "${RegionRef}-docker.pkg.dev/someproject/somerepo/inbound-agent:latest"
		$AgentKeyFileRef = "1234"
		$JenkinsSecretRef = "5678"

		$script:LoopCount = 0

		Mock Write-Host { }

		Mock hostname { $AgentNameRef }

		Mock Get-GCEInstanceMetadata -ParameterFilter { $Key -eq "jenkins-url" } { $JenkinsURLRef }
		Mock Get-GCEInstanceMetadata -ParameterFilter { $Key -eq "agent-image-url" } { $AgentImageURLRef }
		Mock Get-GCEInstanceMetadata { throw "Invalid invocation of Get-GCEInstanceMetadata" }

		Mock Get-GCESecret -ParameterFilter { $Key -eq "agent-key-file" } { $AgentKeyFileRef }
		Mock Get-GCESecret -ParameterFilter { $Key -eq "${AgentNameRef}-secret" } { if ($script:LoopCount -lt 3) { $script:LoopCount++; $null } else { $JenkinsSecretRef } }
		Mock Get-GCESecret { throw "Invalid invocation of Get-GCESecret" }

		Mock Authenticate-DockerForGoogleArtifactRegistry -ParameterFilter { ($AgentKey -eq $AgentKeyFileRef) -and ($Region -eq $RegionRef) } {}
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Invalid invocation of Authenticate-DockerForGoogleArtifactRegistry" }

		Mock Run-JenkinsAgent -ParameterFilter { ($JenkinsURL -eq $JenkinsURLRef) -and ($JenkinsSecret -eq $JenkinsSecretRef) -and ($AgentImageURL -eq $AgentImageURLRef) -and ($AgentName -eq $AgentNameRef) } { }
		Mock Run-JenkinsAgent { throw "Invalid invocation of Run-JenkinsAgent" }

		Mock Start-Sleep { }

		{ & ${PSScriptRoot}\GCEService.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Times 3 Get-GCEInstanceMetadata -ParameterFilter { $Key -eq "jenkins-url" }
		Assert-MockCalled -Times 3 Get-GCEInstanceMetadata -ParameterFilter { $Key -eq "agent-image-url" }
		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "agent-key-file" }
		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "test-host-secret" }

		Assert-MockCalled -Times 2 Start-Sleep

		Assert-MockCalled -Times 1 Run-JenkinsAgent
	}
}