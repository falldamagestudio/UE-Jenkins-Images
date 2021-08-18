. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Copy-SystemDLLs.ps1

}

Describe 'Copy-SystemDLLs' {

	It "Reports error if path join fails" {

		Mock Join-Path { throw "Join-Path failed" }

		Mock Copy-Item { }

		{ Copy-SystemDLLs -SourceFolder . -TargetFolder "c:\Windows\System32" } |
			Should -Throw "Join-Path Failed"

		Assert-MockCalled -Times 0 Copy-Item
	}

	It "Reports error if copy fails" {

		Mock Join-Path { "C:\ExamplePath\xinput1_3.dll" }

		Mock Copy-Item { throw "Copy-Item failed" }

		{ Copy-SystemDLLs -SourceFolder . -TargetFolder "c:\Windows\System32" } |
			Should -Throw "Copy-Item Failed"

		Assert-MockCalled -Times 1 Copy-Item
	}

	It "Reports success if copy succeeds" {

		Mock Join-Path { "C:\ExamplePath\xinput1_3.dll" }

		Mock Copy-Item { }

		{ Copy-SystemDLLs -SourceFolder . -TargetFolder "c:\Windows\System32" } |
			Should -Not -Throw "Copy-Item Failed"

		Assert-MockCalled -Times 7 Copy-Item
	}

}