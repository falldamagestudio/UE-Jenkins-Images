. ${PSScriptRoot}\..\Tools\Scripts\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\Tools\Scripts\Resize-PartitionToMaxSize.ps1
	. ${PSScriptRoot}\..\Tools\Scripts\Get-GCESecret.ps1
	. ${PSScriptRoot}\..\Tools\Scripts\Get-GCEInstanceHostname.ps1
	. ${PSScriptRoot}\..\Tools\Scripts\Authenticate-DockerForGoogleArtifactRegistry.ps1
	. ${PSScriptRoot}\..\Tools\Scripts\Run-SwarmAgent.ps1
}

Describe 'GCEService-SwarmAgent' {

	It "Retries settings fetch until parameters are available" {

		$AgentNameRef = "test-host"
		$RegionRef = "europe-west1"
		$JenkinsURLRef = "http://jenkins"
		$AgentImageURLRef = "${RegionRef}-docker.pkg.dev/someproject/somerepo/swarm-agent:latest"
		$AgentKeyFileRef = "1234"
		$AgentUsernameRef = "admin@example.com"
		$AgentAPITokenRef = "5678"
		$NumExecutorsRef = 1
		$LabelsRef = @( $AgentNameRef )
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
		Mock Get-GCESecret -ParameterFilter { $Key -eq "swarm-agent-image-url-windows" } { $AgentImageURLRef }
		Mock Get-GCESecret -ParameterFilter { $Key -eq "swarm-agent-username" } { $AgentUsernameRef }
		Mock Get-GCESecret -ParameterFilter { $Key -eq "swarm-agent-api-token" } { if ($script:LoopCount -lt 3) { $script:LoopCount++; $null } else { $AgentAPITokenRef } }
		Mock Get-GCESecret -ParameterFilter { $Key -eq "plastic-config-zip" } { $PlasticConfigZipRef }
		Mock Get-GCESecret { throw "Invalid invocation of Get-GCESecret" }

		Mock Expand-Archive { }

		Mock Authenticate-DockerForGoogleArtifactRegistry -ParameterFilter { ($AgentKey -eq $AgentKeyFileRef) -and ($Region -eq $RegionRef) } {}
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Invalid invocation of Authenticate-DockerForGoogleArtifactRegistry" }

		# TODO: validate $Labels
		Mock Run-SwarmAgent -ParameterFilter { ($JenkinsURL -eq $JenkinsURLRef) -and ($AgentUsername -eq $AgentUsernameRef) -and ($AgentAPIToken -eq $AgentAPITokenRef) -and ($AgentImageURL -eq $AgentImageURLRef) -and ($NumExecutors -eq $NumExecutorsRef) -and ($AgentName -eq $AgentNameRef) } { }
		Mock Run-SwarmAgent { throw "Invalid invocation of Run-SwarmAgent" }

		Mock Start-Sleep { if ($script:SleepCount -lt 10) { $script:SleepCount++ } else { throw "Infinite loop detected when waiting for GCE secrets to be set" } }

		{ & ${PSScriptRoot}\GCEService-SwarmAgent.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "jenkins-url" }
		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "agent-key-file" }
		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "swarm-agent-image-url-windows" }
		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "swarm-agent-username" }
		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "swarm-agent-api-token" }
		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "plastic-config-zip" }

		Assert-MockCalled -Times 2 Start-Sleep

		Assert-MockCalled -Times 1 Expand-Archive

		Assert-MockCalled -Times 1 Authenticate-DockerForGoogleArtifactRegistry

		Assert-MockCalled -Times 1 Run-SwarmAgent
	}
}