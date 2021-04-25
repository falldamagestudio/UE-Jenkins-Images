. ${PSScriptRoot}\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Authenticate-GoogleCloudADC.ps1

}

Describe 'Authenticate-GoogleCloudADC' {

	It "succeeds beautifully" {

		Mock Out-File { }

		Authenticate-GoogleCloudADC -AgentKey "5678"

		Assert-MockCalled -Times 1 Out-File
	}
}