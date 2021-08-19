. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-JenkinsRemotingAgent.ps1

}

Describe 'Install-JenkinsRemotingAgent' {

	It "Reports error if downloading agent jar fails" {

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }
		Mock Get-FileHash { throw "Get-FileHash should not be called" }

		{ Install-JenkinsRemotingAgent } |
			Should -Throw "Invoke-WebRequest failed"

		Assert-MockCalled -Exactly -Times 1 Invoke-WebRequest
		Assert-MockCalled -Exactly -Times 0 Get-FileHash
	}

	It "Reports error if downloading sha1 hash fails" {

		Mock Invoke-WebRequest -ParameterFilter { $Uri.AbsoluteUri.EndsWith(".jar") } { }
		Mock Invoke-WebRequest -ParameterFilter { $Uri.AbsoluteUri.EndsWith("jar.sha1") } { throw "Invoke-WebRequest for sha1 hash failed" }
		Mock Invoke-WebRequest { throw "Invalid invocation of Invoke-WebRequest" }
		Mock Get-FileHash { throw "Get-FileHash should not be called" }

		{ Install-JenkinsRemotingAgent } |
			Should -Throw "Invoke-WebRequest for sha1 hash failed"

		Assert-MockCalled -Exactly -Times 2 Invoke-WebRequest
		Assert-MockCalled -Exactly -Times 0 Get-FileHash
	}

	It "Reports error if computing file hash fails" {

		Mock Invoke-WebRequest -ParameterFilter { $Uri.AbsoluteUri.EndsWith(".jar") } { }
		Mock Invoke-WebRequest -ParameterFilter { $Uri.AbsoluteUri.EndsWith("jar.sha1") } { @{ Content = "hash 1" } }
		Mock Invoke-WebRequest { throw "Invalid invocation of Invoke-WebRequest" }
		Mock Get-FileHash { throw "Get-FileHash failed" }

		{ Install-JenkinsRemotingAgent } |
			Should -Throw "Get-FileHash failed"

		Assert-MockCalled -Exactly -Times 2 Invoke-WebRequest
		Assert-MockCalled -Exactly -Times 1 Get-FileHash
	}

	It "Reports error if hashes do not match" {

		Mock Invoke-WebRequest -ParameterFilter { $Uri.AbsoluteUri.EndsWith(".jar") } { }
		Mock Invoke-WebRequest -ParameterFilter { $Uri.AbsoluteUri.EndsWith("jar.sha1") } { @{ Content = "hash 1" } }
		Mock Invoke-WebRequest { throw "Invalid invocation of Invoke-WebRequest" }
		Mock Get-FileHash { return @{ Hash = "hassh 2"} }

		{ Install-JenkinsRemotingAgent } |
			Should -Throw

		Assert-MockCalled -Exactly -Times 2 Invoke-WebRequest
		Assert-MockCalled -Exactly -Times 1 Get-FileHash
	}

	It "Reports success if hashes match" {

		Mock Invoke-WebRequest -ParameterFilter { $Uri.AbsoluteUri.EndsWith(".jar") } { }
		Mock Invoke-WebRequest -ParameterFilter { $Uri.AbsoluteUri.EndsWith("jar.sha1") } { @{ Content = "hash 1" } }
		Mock Invoke-WebRequest { throw "Invalid invocation of Invoke-WebRequest" }
		Mock Get-FileHash { return @{ Hash = "hash 1"} }

		{ Install-JenkinsRemotingAgent } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 2 Invoke-WebRequest
		Assert-MockCalled -Exactly -Times 1 Get-FileHash
	}
}