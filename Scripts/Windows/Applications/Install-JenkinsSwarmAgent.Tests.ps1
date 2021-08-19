. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-JenkinsSwarmAgent.ps1

}

Describe 'Install-JenkinsSwarmAgent' {

# HACK: Comment out while we are copying this from local location instead of downloading from the internet
#
#	It "Reports error if downloading agent jar fails" {
#
#		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }
#
#		{ Install-JenkinsSwarmAgent -Path "C:\Jenkins" } |
#			Should -Throw "Invoke-WebRequest failed"
#
#		Assert-MockCalled -Exactly -Times 1 Invoke-WebRequest
#	}
#
#	It "Reports success if download is successful" {
#
#		Mock Invoke-WebRequest { }
#
#		{ Install-JenkinsSwarmAgent -Path "C:\Jenkins" } |
#			Should -Not -Throw
#
#		Assert-MockCalled -Exactly -Times 1 Invoke-WebRequest
#	}
}