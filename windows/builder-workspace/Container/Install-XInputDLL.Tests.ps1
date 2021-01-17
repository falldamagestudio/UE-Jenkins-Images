. ${PSScriptRoot}\..\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-XInputDLL.ps1

}

Describe 'Install-XInputDLL' {

	It "Reports error if path join fails" {

		Mock Join-Path { throw "Join-Path failed" }

		Mock Copy-Item { }

		{ Install-XInputDLL } |
			Should -Throw "Join-Path Failed"

		Assert-MockCalled -Times 0 Copy-Item
	}

	It "Reports error if copy fails" {

		Mock Join-Path { "C:\ExamplePath\xinput1_3.dll" }

		Mock Copy-Item { throw "Copy-Item failed" }

		{ Install-XInputDLL } |
			Should -Throw "Copy-Item Failed"

		Assert-MockCalled -Times 1 Copy-Item
	}

	It "Reports success if copy succeeds" {

		Mock Join-Path { "C:\ExamplePath\xinput1_3.dll" }

		Mock Copy-Item { }

		{ Install-XInputDLL } |
			Should -Not -Throw "Copy-Item Failed"

		Assert-MockCalled -Times 1 Copy-Item
	}

}