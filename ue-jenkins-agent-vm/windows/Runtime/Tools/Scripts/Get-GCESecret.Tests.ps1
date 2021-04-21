. ${PSScriptRoot}\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Get-GCESecret.ps1

}

Describe 'Get-GCESecret' {

	It "Throws an exception if docker cannot be found or returns an error" {

		Mock Start-Process-WithStdio { return 1234, "", "" }

		Get-GCESecret -Key "abc" | Should -Be $null

		Assert-MockCalled -Times 1 Start-Process-WithStdio -ParameterFilter { $FilePath -eq "powershell" }
	}

	It "succeeds if Docker returns a zero error code" {

		Mock Start-Process-WithStdio { return 0, "1234", "" }

		Get-GCESecret -Key "abc" | Should -Be "1234"

		Assert-MockCalled -Times 1 Start-Process-WithStdio -ParameterFilter { $FilePath -eq "powershell" }
	}
}