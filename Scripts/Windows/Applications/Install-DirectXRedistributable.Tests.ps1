. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-DirectXRedistributable.ps1

}

Describe 'Install-DirectXRedistributable' {

	It "Reports success if Start-Process returns zero, and removes temp folder" {

		Mock New-Item { }

		Mock Join-Path { "C:\ExamplePath" }

		Mock Invoke-WebRequest { }

		Mock Start-Process { @{ ExitCode = 0 } }

		Mock Remove-Item { }

		{ Install-DirectXRedistributable } |
			Should -Not -Throw

		Assert-MockCalled -Times 1 Remove-Item
	}

}