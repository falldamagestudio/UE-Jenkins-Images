. ${PSScriptRoot}\..\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-DockerCredentialGCR.ps1

}

Describe 'Install-DockerCredentialGCR' {

	It "Reports error if temp folder cannot be created" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { throw "NewItem cannot be created for temp folder" }

		Mock Join-Path { throw "Join-Path failed" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock New-Item -ParameterFilter { $Path -eq "C:\Program Files\docker-credential-gcr" } { throw "NewItem cannot be created for application folder" }

        Mock tar { throw "tar failed" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		Mock Remove-Item { }

		Mock New-Item { throw "Invalid New-Item invocation" }

		{ Install-DockerCredentialGCR } |
			Should -Throw "NewItem cannot be created for temp folder"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 0 Join-Path
		Assert-MockCalled -Times 0 Invoke-WebRequest
		Assert-MockCalled -Times 0 tar
		Assert-MockCalled -Times 0 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
	}

	It "Reports error if Join-Path fails" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path { throw "Join-Path failed" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock New-Item -ParameterFilter { $Path -eq "C:\Program Files\docker-credential-gcr" } { throw "NewItem cannot be created for application folder" }

        Mock tar { throw "tar failed" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		Mock Remove-Item { }

		Mock New-Item { throw "Invalid New-Item invocation" }

		{ Install-DockerCredentialGCR } |
			Should -Throw "Join-Path failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 0 Invoke-WebRequest
		Assert-MockCalled -Times 0 tar
		Assert-MockCalled -Times 0 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
	}

	It "Reports error if Invoke-WebRequest fails" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path { "C:\Temp\docker-credential-gcr.tgz" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

		Mock New-Item -ParameterFilter { $Path -eq "C:\Program Files\docker-credential-gcr" } { throw "NewItem cannot be created for application folder" }

        Mock tar { throw "tar failed" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		Mock Remove-Item { }

		Mock New-Item { throw "Invalid New-Item invocation" }

		{ Install-DockerCredentialGCR } |
			Should -Throw "Invoke-WebRequest failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 0 tar
		Assert-MockCalled -Times 0 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
	}

	It "Reports error if application folder cannot be created" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path { "C:\Temp\docker-credential-gcr.tgz" }

		Mock Invoke-WebRequest { $OutFile | Should -Be "C:\Temp\docker-credential-gcr.tgz" }

		Mock New-Item -ParameterFilter { $Path -eq "C:\Program Files\docker-credential-gcr" } { throw "NewItem cannot be created for application folder" }

        Mock tar { throw "tar failed" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		Mock Remove-Item { }

		Mock New-Item { throw "Invalid New-Item invocation" }

		{ Install-DockerCredentialGCR } |
			Should -Throw "NewItem cannot be created for application folder"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 0 tar
		Assert-MockCalled -Times 0 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
	}

	It "Reports error if tar fails" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path { "C:\Temp\docker-credential-gcr.tgz" }

		Mock Invoke-WebRequest { $OutFile | Should -Be "C:\Temp\docker-credential-gcr.tgz" }

		Mock New-Item -ParameterFilter { $Path -eq "C:\Program Files\docker-credential-gcr" } { }

        Mock tar { throw "tar failed" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		Mock Remove-Item { }

		Mock New-Item { throw "Invalid New-Item invocation" }

		{ Install-DockerCredentialGCR } |
			Should -Throw "tar failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 tar
		Assert-MockCalled -Times 0 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
	}

	It "Reports error if Get-ItemProperty fails" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path { "C:\Temp\docker-credential-gcr.tgz" }

		Mock Invoke-WebRequest { $OutFile | Should -Be "C:\Temp\docker-credential-gcr.tgz" }

		Mock New-Item -ParameterFilter { $Path -eq "C:\Program Files\docker-credential-gcr" } { }

        Mock tar { }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		Mock Remove-Item { }

		Mock New-Item { throw "Invalid New-Item invocation" }

		{ Install-DockerCredentialGCR } |
			Should -Throw "Get-ItemProperty failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 tar
		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
	}

	It "Reports error if Set-ItemProperty fails" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path { "C:\Temp\docker-credential-gcr.tgz" }

		Mock Invoke-WebRequest { $OutFile | Should -Be "C:\Temp\docker-credential-gcr.tgz" }

		Mock New-Item -ParameterFilter { $Path -eq "C:\Program Files\docker-credential-gcr" } { }

        Mock tar { }

		Mock Get-ItemProperty { return @{ Path = "C:\FirstFolder;C:\SecondFolder" } }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		Mock Remove-Item { }

		Mock New-Item { throw "Invalid New-Item invocation" }

		{ Install-DockerCredentialGCR } |
			Should -Throw "Set-ItemProperty failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 tar
		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 1 Set-ItemProperty
	}

	It "Reports success if all steps succeed" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path { "C:\Temp\docker-credential-gcr.tgz" }

		Mock Invoke-WebRequest { $OutFile | Should -Be "C:\Temp\docker-credential-gcr.tgz" }

		Mock New-Item -ParameterFilter { $Path -eq "C:\Program Files\docker-credential-gcr" } { }

        Mock tar { }

		Mock Get-ItemProperty { return @{ Path = "C:\FirstFolder;C:\SecondFolder" } }
		Mock Set-ItemProperty { $Name | Should -Be "PATH"; $Value | Should -Be "C:\FirstFolder;C:\SecondFolder;C:\Program Files\docker-credential-gcr" }

		Mock Remove-Item { }

		Mock New-Item { throw "Invalid New-Item invocation" }

		{ Install-DockerCredentialGCR } |
			Should -Not -Throw

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 tar
		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 1 Set-ItemProperty
	}
}