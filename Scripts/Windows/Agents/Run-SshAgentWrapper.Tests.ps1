
. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\SystemConfiguration\Get-GCESecret.ps1
	. ${PSScriptRoot}\Run\Run-SshAgent.ps1
	. ${PSScriptRoot}\..\Applications\Authenticate-DockerForGoogleArtifactRegistry.ps1
}

Describe 'Run-SshAgentWrapper' {

	It "Succeeds when launched with -fullversion" {

		Mock Start-Transcript { }
		Mock Resolve-Path { "invalid path" }
		Mock Get-Date { "invalid date" }
		Mock Stop-Transcript { }

		Mock Write-Host { }

		Mock Get-GCESecret { throw "Get-GCESecret should not be called" }

		Mock Expand-Archive { throw "Expand-Archive should not be called" }
		Mock Remove-Item { throw "Remove-Item should not be called" }

		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry should not be called" }

		Mock Run-SshAgent { throw "Run-SshAgent should not be called" }

		Mock Start-Sleep { throw "Start-Sleep should not be called" }

		Mock New-Item { throw "New-Item should not be called" }
		Mock Copy-Item { throw "Copy-Item should not be called" }

		Mock Run-SshAgent { throw "Run-SshAgent should not be called" }

		{ & ${PSScriptRoot}\Run-SshAgentWrapper.ps1 -fullversion } |
			Should -Not -Throw
	}

	It "Fails when launched without any options" {

		Mock Start-Transcript { }
		Mock Resolve-Path { "invalid path" }
		Mock Get-Date { "invalid date" }
		Mock Stop-Transcript { }

		Mock Write-Host { }

		Mock Get-GCESecret { throw "Get-GCESecret should not be called" }

		Mock Expand-Archive { throw "Expand-Archive should not be called" }
		Mock Remove-Item { throw "Remove-Item should not be called" }

		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Authenticate-DockerForGoogleArtifactRegistry should not be called" }

		Mock Run-SshAgent { throw "Run-SshAgent should not be called" }

		Mock Start-Sleep { throw "Start-Sleep should not be called" }

		Mock New-Item { throw "New-Item should not be called" }
		Mock Copy-Item { throw "Copy-Item should not be called" }

		Mock Run-SshAgent { throw "Run-SshAgent should not be called" }

		{ & ${PSScriptRoot}\Run-SshAgentWrapper.ps1 } |
			Should -Throw
	}

	It "Succeeds when launched with -jar <jarfile>; retries settings fetch until parameters are available before launching SshAgent" {

		$RegionRef = "europe-west1"
		$AgentImageURLRef = "${RegionRef}-docker.pkg.dev/someproject/somerepo/swarm-agent:latest"
		$AgentKeyFileRef = "1234"
		$PlasticConfigZipRef = @(72, 101, 108, 108, 111) # "Hello"

		$script:LoopCount = 0
		$script:SleepCount = 0

		Mock Start-Transcript { }
		Mock Resolve-Path { "invalid path" }
		Mock Get-Date { "invalid date" }
		Mock Stop-Transcript { }

		Mock Write-Host { }

		Mock Get-GCESecret -ParameterFilter { $Key -eq "agent-key-file" } { $AgentKeyFileRef }
		Mock Get-GCESecret -ParameterFilter { $Key -eq "ssh-agent-image-url-windows" } { if ($script:LoopCount -lt 3) { $script:LoopCount++; $null } else { $AgentImageURLRef } }
		Mock Get-GCESecret -ParameterFilter { $Key -eq "plastic-config-zip" } { $PlasticConfigZipRef }
		Mock Get-GCESecret { throw "Invalid invocation of Get-GCESecret" }

		Mock Expand-Archive { }
		Mock Remove-Item { }

		Mock Authenticate-DockerForGoogleArtifactRegistry -ParameterFilter { ($AgentKey -eq $AgentKeyFileRef) -and ($Region -eq $RegionRef) } {}
		Mock Authenticate-DockerForGoogleArtifactRegistry { throw "Invalid invocation of Authenticate-DockerForGoogleArtifactRegistry" }

		Mock New-Item -ParameterFilter { ($ItemType -eq "Directory") } { }
		Mock New-Item { throw "Invalid invocation of New-Item" }

		Mock Copy-Item { }

		Mock Run-SshAgent -ParameterFilter { ($AgentImageURL -eq $AgentImageURLRef) } { }
		Mock Run-SshAgent { throw "Invalid invocation of Run-SshAgent" }

		Mock Start-Sleep { if ($script:SleepCount -lt 10) { $script:SleepCount++ } else { throw "Infinite loop detected when waiting for GCE secrets to be set" } }

		{ & ${PSScriptRoot}\Run-SshAgentWrapper.ps1 -jar "C:\AgentJarDownloadLocation\agent.jar" } |
			Should -Not -Throw

		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "agent-key-file" }
		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "ssh-agent-image-url-windows" }
		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "plastic-config-zip" }

		Assert-MockCalled -Times 2 Start-Sleep

		Assert-MockCalled -Times 1 Expand-Archive
		Assert-MockCalled -Times 1 Remove-Item

		Assert-MockCalled -Times 1 Authenticate-DockerForGoogleArtifactRegistry

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Copy-Item

		Assert-MockCalled -Times 1 Run-SshAgent
	}
}