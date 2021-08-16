. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Authenticate-DockerForGoogleArtifactRegistry.ps1
	. ${PSScriptRoot}\..\Helpers\Invoke-External-WithStdio.ps1

}

Describe 'Authenticate-DockerForGoogleArtifactRegistry' {

	It "Throws an exception if docker cannot be found or returns an error" {

		Mock Invoke-External-WithStdio { return 1234, "", "" }

		{ Authenticate-DockerForGoogleArtifactRegistry -AgentKey "5678" -Region "europe-west1" } |
			Should -Throw

		Assert-MockCalled -Times 1 Invoke-External-WithStdio -ParameterFilter { $LiteralPath -eq "powershell" }
	}

	It "succeeds if Docker returns a zero error code" {

		Mock Invoke-External-WithStdio { return 0, "", "" }

		{ Authenticate-DockerForGoogleArtifactRegistry -AgentKey "5678" -Region "europe-west1" } |
			Should -Not -Throw

		Assert-MockCalled -Times 1 Invoke-External-WithStdio -ParameterFilter { $LiteralPath -eq "powershell" }
	}
}