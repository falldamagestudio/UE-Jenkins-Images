. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-GoogleCloudOpsAgent.ps1

}

Describe 'Install-GoogleCloudOpsAgent' {

	It "Reports error if temp folder cannot be created" {

		Mock New-Item { throw "NewItem cannot be created" }

		Mock Join-Path { throw "Join-Path failed" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock Invoke-Expression { throw "Invoke-Expression failed" }

		Mock Remove-Item { }

		{ Install-GoogleCloudOpsAgent } |
			Should -Throw "NewItem cannot be created"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 0 Join-Path
		Assert-MockCalled -Times 0 Invoke-WebRequest
		Assert-MockCalled -Times 0 Invoke-Expression
		Assert-MockCalled -Times 0 Remove-Item
	}

	It "Reports error if Join-Path fails, and removes temp folder" {

		Mock New-Item { }

		Mock Join-Path { throw "Join-Path failed" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock Remove-Item { }

		Mock Invoke-Expression { throw "Invoke-Expression failed" }

		{ Install-GoogleCloudOpsAgent } |
			Should -Throw "Join-Path failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 0 Invoke-WebRequest
		Assert-MockCalled -Times 0 Invoke-Expression
		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports error if Invoke-WebRequest fails, and removes temp folder" {

		Mock New-Item { }

		Mock Join-Path { "C:\ExamplePath" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock Remove-Item { }

		Mock Invoke-Expression { throw "Invoke-Expression failed" }

		{ Install-GoogleCloudOpsAgent } |
			Should -Throw "Invoke-WebRequest failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 0 Invoke-Expression
		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports success if Invoke-Expression succeeds, and removes temp folder" {

		Mock New-Item { }

		Mock Join-Path { "C:\ExamplePath" }

		Mock Invoke-WebRequest { }

		Mock Invoke-Expression { }

		Mock Remove-Item { }

		{ Install-GoogleCloudOpsAgent } |
			Should -Not -Throw

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 Invoke-Expression
		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports error if Invoke-Expression fails, and removes temp folder" {

		Mock New-Item { }

		Mock Join-Path { "C:\ExamplePath" }

		Mock Invoke-WebRequest { }

		Mock Invoke-Expression { throw "Invoke-Expression failed" }

		Mock Remove-Item { }

		{ Install-GoogleCloudOpsAgent } |
			Should -Throw "Invoke-Expression failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 Invoke-Expression
		Assert-MockCalled -Times 1 Remove-Item
	}

}