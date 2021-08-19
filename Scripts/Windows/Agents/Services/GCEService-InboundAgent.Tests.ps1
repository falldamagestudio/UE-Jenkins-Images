. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\..\SystemConfiguration\Resize-PartitionToMaxSize.ps1
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESecret.ps1
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCEInstanceHostname.ps1
	. ${PSScriptRoot}\..\Run\Run-InboundAgent.ps1
}

Describe 'GCEService-InboundAgent' {

	It "Retries settings fetch until parameters are available" {

		$AgentNameRef = "test-host"
		$RegionRef = "europe-west1"
		$JenkinsURLRef = "http://jenkins"
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
		Mock Get-GCESecret -ParameterFilter { $Key -eq "inbound-agent-secret-${AgentNameRef}" } { $script:LoopCount++; if ($script:LoopCount -lt 3) { $null } else { $JenkinsSecretRef } }
		Mock Get-GCESecret -ParameterFilter { $Key -eq "plastic-config-zip" } { $PlasticConfigZipRef }
		Mock Get-GCESecret { throw "Invalid invocation of Get-GCESecret" }

		Mock Expand-Archive { }

		Mock Run-InboundAgent -ParameterFilter { ($JenkinsURL -eq $JenkinsURLRef) -and ($JenkinsSecret -eq $JenkinsSecretRef) -and ($AgentName -eq $AgentNameRef) } { }
		Mock Run-InboundAgent { throw "Invalid invocation of Run-InboundAgent" }

		Mock Start-Sleep { if ($script:SleepCount -lt 10) { $script:SleepCount++ } else { throw "Infinite loop detected when waiting for GCE secrets to be set" } }

		{ & ${PSScriptRoot}\GCEService-InboundAgent.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "jenkins-url" }
		Assert-MockCalled -Exactly -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "inbound-agent-secret-${AgentNameRef}" }
		Assert-MockCalled -Exactly -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "plastic-config-zip" }

		Assert-MockCalled -Exactly -Times 2 Start-Sleep

		Assert-MockCalled -Exactly -Times 1 Expand-Archive

		Assert-MockCalled -Exactly -Times 1 Run-InboundAgent
	}
}