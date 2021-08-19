. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-JenkinsRemotingAgent.ps1

}

Describe 'Install-JenkinsRemotingAgent' {

	It "Reports error if downloading agent jar fails" {

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }
		Mock Invoke-RestMethod { throw "Invoke-RestMethod should not be called" }
		Mock Get-FileHash { throw "Get-FileHash should not be called" }

		{ Install-JenkinsRemotingAgent -Path "C:\Jenkins" } |
			Should -Throw "Invoke-WebRequest failed"

		Assert-MockCalled -Exactly -Times 1 Invoke-WebRequest
		Assert-MockCalled -Exactly -Times 0 Invoke-RestMethod
		Assert-MockCalled -Exactly -Times 0 Get-FileHash
	}

	It "Reports error if downloading sha1 hash fails" {

		Mock Invoke-WebRequest { }
		Mock Invoke-RestMethod { throw "Invoke-RestMethod for sha1 hash failed" }
		Mock Get-FileHash { throw "Get-FileHash should not be called" }

		{ Install-JenkinsRemotingAgent -Path "C:\Jenkins" } |
			Should -Throw "Invoke-RestMethod for sha1 hash failed"

		Assert-MockCalled -Exactly -Times 1 Invoke-WebRequest
		Assert-MockCalled -Exactly -Times 1 Invoke-RestMethod
		Assert-MockCalled -Exactly -Times 0 Get-FileHash
	}

	It "Reports error if computing file hash fails" {

		Mock Invoke-WebRequest { }
		Mock Invoke-RestMethod { "hash 1" }
		Mock Get-FileHash { throw "Get-FileHash failed" }

		{ Install-JenkinsRemotingAgent -Path "C:\Jenkins" } |
			Should -Throw "Get-FileHash failed"

		Assert-MockCalled -Exactly -Times 1 Invoke-WebRequest
		Assert-MockCalled -Exactly -Times 1 Invoke-RestMethod
		Assert-MockCalled -Exactly -Times 1 Get-FileHash
	}

	It "Reports error if hashes do not match" {

		Mock Invoke-WebRequest { }
		Mock Invoke-RestMethod { "hash 1" }
		Mock Get-FileHash { return @{ Hash = "hash 2"} }

		{ Install-JenkinsRemotingAgent -Path "C:\Jenkins" } |
			Should -Throw

		Assert-MockCalled -Exactly -Times 1 Invoke-WebRequest
		Assert-MockCalled -Exactly -Times 1 Invoke-RestMethod
		Assert-MockCalled -Exactly -Times 1 Get-FileHash
	}

	It "Reports success if hashes match" {

		Mock Invoke-WebRequest { }
		Mock Invoke-RestMethod { "hash 1" }
		Mock Get-FileHash { return @{ Hash = "hash 1"} }

		{ Install-JenkinsRemotingAgent -Path "C:\Jenkins" } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Invoke-WebRequest
		Assert-MockCalled -Exactly -Times 1 Invoke-RestMethod
		Assert-MockCalled -Exactly -Times 1 Get-FileHash
	}
}