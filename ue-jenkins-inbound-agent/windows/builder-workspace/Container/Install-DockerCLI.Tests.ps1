. ${PSScriptRoot}\..\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-DockerCLI.ps1

}

Describe 'Install-DockerCLI' {

	It "Reports error if Join-Path fails" {

		Mock Join-Path { throw "Join-Path failed" }

		Mock New-Item { throw "NewItem cannot be created" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		{ Install-DockerCLI } |
			Should -Throw "Join-Path failed"

		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 0 New-Item
		Assert-MockCalled -Times 0 Invoke-WebRequest
		Assert-MockCalled -Times 0 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
	}

	It "Reports error if Docker folder cannot be created" {

		Mock Join-Path { "C:\Program Files\Docker\Docker.exe" }

		Mock New-Item { throw "NewItem cannot be created" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		{ Install-DockerCLI } |
			Should -Throw "NewItem cannot be created"

		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 0 Invoke-WebRequest
		Assert-MockCalled -Times 0 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
	}

	It "Reports error if Invoke-WebRequest fails" {

		Mock Join-Path { "C:\Program Files\Docker\Docker.exe" }

		Mock New-Item { $Path | Should -Be "C:\Program Files\Docker" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		{ Install-DockerCLI } |
			Should -Throw "Invoke-WebRequest failed"

		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 0 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
	}

	It "Reports error if Get-ItemProperty fails" {

		Mock Join-Path { "C:\Program Files\Docker\Docker.exe" }

		Mock New-Item { $Path | Should -Be "C:\Program Files\Docker" }

		Mock Invoke-WebRequest { $OutFile | Should -Be "C:\Program Files\Docker\Docker.exe" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		{ Install-DockerCLI } |
			Should -Throw "Get-ItemProperty failed"

		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
	}

	It "Reports error if Set-ItemProperty fails" {

		Mock Join-Path { "C:\Program Files\Docker\Docker.exe" }

		Mock New-Item { $Path | Should -Be "C:\Program Files\Docker" }

		Mock Invoke-WebRequest { $OutFile | Should -Be "C:\Program Files\Docker\Docker.exe" }

		Mock Get-ItemProperty { return @{ Path = "C:\FirstFolder;C:\SecondFolder" } }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		{ Install-DockerCLI } |
			Should -Throw "Set-ItemProperty failed"

		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 1 Set-ItemProperty
	}

	It "Reports success if all steps succeed" {

		Mock Join-Path { "C:\Program Files\Docker\Docker.exe" }

		Mock New-Item { $Path | Should -Be "C:\Program Files\Docker" }

		Mock Invoke-WebRequest { $OutFile | Should -Be "C:\Program Files\Docker\Docker.exe" }

		Mock Get-ItemProperty { return @{ Path = "C:\FirstFolder;C:\SecondFolder" } }
		Mock Set-ItemProperty { $Name | Should -Be "PATH"; $Value | Should -Be "C:\FirstFolder;C:\SecondFolder;C:\Program Files\Docker" }

		{ Install-DockerCLI } |
			Should -Not -Throw

		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 1 Set-ItemProperty
	}

}