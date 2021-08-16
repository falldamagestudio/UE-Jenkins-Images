. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Get-GCEInstanceMetadata.ps1

}

Describe 'Get-GCEInstanceMetadata' {

	It "Returns the value of an existing instance tag appropriately" {
		
		$RawResponse = [System.Byte[]]::new(3)
		$RawResponse[0] = [byte][char]'a'
		$RawResponse[1] = [byte][char]'b'
		$RawResponse[2] = [byte][char]'c'

		Mock Invoke-WebRequest { return @{ Content = $RawResponse } }

		$Value = Get-GCEInstanceMetadata -Key "testkey"

		Assert-MockCalled Invoke-WebRequest -ParameterFilter { $Uri -eq "http://metadata.google.internal/computeMetadata/v1/instance/attributes/testkey" }

		$Value | Should -Be "abc"
	}

	It "Returns null if the instance tag doesn't exist" {
		
		Mock Invoke-WebRequest { return $null }

		$Value = Get-GCEInstanceMetadata -Key "testkey"

		Assert-MockCalled Invoke-WebRequest -ParameterFilter { $Uri -eq "http://metadata.google.internal/computeMetadata/v1/instance/attributes/testkey" }

		$Value | Should -Be $null
	}
}