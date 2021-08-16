. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Get-GCEInstanceHostname.ps1

}

Describe 'Get-GCEInstanceHostname' {

	It "Returns null there is an error during name fetch" {
		
		Mock Invoke-RestMethod { throw "error while fetching hostname" }

		$Value = Get-GCEInstanceHostname

		Assert-MockCalled Invoke-RestMethod -ParameterFilter { $Uri -eq "http://metadata.google.internal/computeMetadata/v1/instance/hostname" }

		$Value | Should -Be $null
	}

	It "Returns the hostname when successful" {
		
		Mock Invoke-RestMethod { return "test-host.c.testproject.internal" }

		$Value = Get-GCEInstanceHostname

		Assert-MockCalled Invoke-RestMethod -ParameterFilter { $Uri -eq "http://metadata.google.internal/computeMetadata/v1/instance/hostname" }

		$Value | Should -Be "test-host.c.testproject.internal"
	}
}