. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-VisualStudioBuildTools.ps1

}

Describe 'Install-VisualStudioBuildTools' {

	It "Reports error if temp folder cannot be created" {

		Mock New-Item { throw "NewItem cannot be created" }

		Mock Join-Path { throw "Join-Path failed" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock Remove-Item { }

		{ Install-VisualStudioBuildTools } |
			Should -Throw "NewItem cannot be created"

		Assert-MockCalled -Times 0 Remove-Item
	}

	It "Reports error if Join-Path fails, and removes temp folder" {

		Mock New-Item { }

		Mock Join-Path { throw "Join-Path failed" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock Remove-Item { }

		{ Install-VisualStudioBuildTools } |
			Should -Throw "Join-Path failed"

		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports error if Invoke-WebRequest fails, and removes temp folder" {

		Mock New-Item { }

		Mock Join-Path { "C:\ExamplePath" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock Remove-Item { }

		{ Install-VisualStudioBuildTools } |
			Should -Throw "Invoke-WebRequest failed"

		Assert-MockCalled -Times 1 Remove-Item
	}

# Temporarily commented out, Pester 5.0.4 on one machine didn't like this
#
#	It "Reports success if Start-Process returns <ExitCode>, and removes temp folder" -ForEach @(
#		@{ ExitCode = 0 }
#		@{ ExitCode = 3010 }
#	) {
#
#		Mock New-Item { }
#
#		Mock Join-Path { "C:\ExamplePath" }
#
#		Mock Invoke-WebRequest { }
#
#		Mock Start-Process { @{ ExitCode = $ExitCode } }
#
#		Mock Remove-Item { }
#
#		{ Install-VisualStudioBuildTools } |
#			Should -Not -Throw
#
#		Assert-MockCalled -Times 1 Remove-Item
#	}

	It "Reports error if Start-Process returns another exit code, and removes temp folder" {

		Mock New-Item { }

		Mock Join-Path { "C:\ExamplePath" }

		Mock Invoke-WebRequest { }

		Mock Start-Process { @{ ExitCode = 1234 } }

		Mock Remove-Item { }

		{ Install-VisualStudioBuildTools } |
			Should -Throw

		Assert-MockCalled -Times 1 Remove-Item
	}

}