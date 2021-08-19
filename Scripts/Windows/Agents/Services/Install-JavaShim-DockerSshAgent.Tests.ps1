. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\Install-JavaShim-DockerSshAgent.ps1
}

Describe 'Install-JavaShim-DockerSshAgent' {

	It "Succeeds only if Copy-Item is called with a valid source file location" {

		Mock Copy-Item { if (!(Test-Path $Path)) { throw "Path must point to an existing script; ${Path} is not valid" } }

		{ Install-JavaShim-DockerSshAgent } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Copy-Item
	}
}