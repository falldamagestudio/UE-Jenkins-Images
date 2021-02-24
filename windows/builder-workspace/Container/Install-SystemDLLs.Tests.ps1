. ${PSScriptRoot}\..\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-SystemDLLs.ps1

}

Describe 'Install-SystemDLLs' {

	It "Reports error if path join fails" {

		Mock Join-Path { throw "Join-Path failed" }

		Mock Copy-Item { }

		{ Install-SystemDLLs } |
			Should -Throw "Join-Path Failed"

		Assert-MockCalled -Times 0 Copy-Item
	}

	It "Reports error if copy fails" {

		Mock Join-Path { "C:\ExamplePath\xinput1_3.dll" }

		Mock Copy-Item { throw "Copy-Item failed" }

		{ Install-SystemDLLs } |
			Should -Throw "Copy-Item Failed"

		Assert-MockCalled -Times 1 Copy-Item
	}

	It "Reports success if copy succeeds" {

		Mock Join-Path { "C:\ExamplePath\xinput1_3.dll" }

		Mock Copy-Item { }

		{ Install-SystemDLLs } |
			Should -Not -Throw "Copy-Item Failed"

		Assert-MockCalled -Times 7 Copy-Item
	}

}