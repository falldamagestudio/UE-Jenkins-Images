. ${PSScriptRoot}\..\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-DebuggingToolsForWindows.ps1
	. ${PSScriptRoot}\Invoke-External.ps1

}

Describe 'Install-DebuggingToolsForWindows' {

	It "Reports error if temp folder cannot be created" {

		Mock New-Item { throw "NewItem cannot be created" }

		Mock Join-Path { throw "Join-Path failed" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock Remove-Item { }

		{ Install-DebuggingToolsForWindows } |
			Should -Throw "NewItem cannot be created"

		Assert-MockCalled -Times 0 Remove-Item
	}

	It "Reports error if Join-Path fails, and removes temp folder" {

		Mock New-Item { }

		Mock Join-Path { throw "Join-Path failed" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock Remove-Item { }

		{ Install-DebuggingToolsForWindows } |
			Should -Throw "Join-Path failed"

		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports error if Invoke-WebRequest fails, and removes temp folder" {

		Mock New-Item { }

		Mock Join-Path { "C:\ExamplePath" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock Remove-Item { }

		{ Install-DebuggingToolsForWindows } |
			Should -Throw "Invoke-WebRequest failed"

		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports success if Invoke-External returns zero, and removes temp folder" {

		Mock New-Item { }

		Mock Join-Path { "C:\ExamplePath" }

		Mock Invoke-WebRequest { }

		Mock Invoke-External { 0 }

		Mock Remove-Item { }

		{ Install-DebuggingToolsForWindows } |
			Should -Not -Throw

		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports error if Invoke-External returns another exit code, and removes temp folder" {

		Mock New-Item { }

		Mock Join-Path { "C:\ExamplePath" }

		Mock Invoke-WebRequest { }

		Mock Invoke-External { 1234 }

		Mock Remove-Item { }

		{ Install-DebuggingToolsForWindows } |
			Should -Throw

		Assert-MockCalled -Times 1 Remove-Item
	}

}