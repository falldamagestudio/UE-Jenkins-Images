. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-GoogleCloudSDK.ps1

}

Describe 'Install-GoogleCloudSDK' {

	It "Reports error if temp folder cannot be created" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { throw "NewItem cannot be created for temp folder" }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { throw "First Join-Path failed" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

        Mock Expand-Archive { throw "expand-archive failed" }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files" } { throw "Second Join-Path failed" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Throw "NewItem cannot be created for temp folder"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 0 Join-Path
		Assert-MockCalled -Times 0 Invoke-WebRequest
		Assert-MockCalled -Times 0 Expand-Archive
		Assert-MockCalled -Times 0 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
	}

	It "Reports error if first Join-Path fails, and removes temp folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { throw "First Join-Path failed" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

        Mock Expand-Archive { throw "expand-archive failed" }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files" } { throw "Second Join-Path failed" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Throw "First Join-Path failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 0 Invoke-WebRequest
		Assert-MockCalled -Times 0 Expand-Archive
		Assert-MockCalled -Times 0 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports error if Invoke-WebRequest fails, and removes temp folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { return "C:\Temp\google-cloud-sdk.zip" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

        Mock Expand-Archive { throw "expand-archive failed" }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files" } { throw "Second Join-Path failed" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Throw "Invoke-WebRequest failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 0 Expand-Archive
		Assert-MockCalled -Times 0 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports error if Expand-Archive fails, and removes temp folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { return "C:\Temp\google-cloud-sdk.zip" }

		Mock Invoke-WebRequest { }

        Mock Expand-Archive { throw "Expand-Archive failed" }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files" } { throw "Second Join-Path failed" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Throw "Expand-Archive failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 Expand-Archive
		Assert-MockCalled -Times 0 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports error if second Join-Path fails, and removes temp folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { return "C:\Temp\google-cloud-sdk.zip" }

		Mock Invoke-WebRequest { }

        Mock Expand-Archive { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files" } { throw "Second Join-Path failed" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Throw "Second Join-Path failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 2 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 Expand-Archive
		Assert-MockCalled -Times 0 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports error if Get-ItemProperty fails, and removes temp folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { return "C:\Temp\google-cloud-sdk.zip" }

		Mock Invoke-WebRequest { }

        Mock Expand-Archive { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files" } { return "C:\Program Files\google-cloud-sdk\bin" }

		Mock Get-ItemProperty { throw "Get-ItemProperty failed" }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Throw "Get-ItemProperty failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 2 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 Expand-Archive
		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 0 Set-ItemProperty
		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports error if Set-ItemProperty fails, and removes temp folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { return "C:\Temp\google-cloud-sdk.zip" }

		Mock Invoke-WebRequest { }

        Mock Expand-Archive { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files" } { return "C:\Program Files\google-cloud-sdk\bin" }

		Mock Get-ItemProperty { @{ Path = "C:\FirstFolder;C:\SecondFolder" } }
		Mock Set-ItemProperty { throw "Set-ItemProperty failed" }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Throw "Set-ItemProperty failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 2 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 Expand-Archive
		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 1 Set-ItemProperty
		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports success if all steps succeed, and removes temp folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { return "C:\Temp\google-cloud-sdk.zip" }

		Mock Invoke-WebRequest { }

        Mock Expand-Archive { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files" } { return "C:\Program Files\google-cloud-sdk\bin" }

		Mock Get-ItemProperty { @{ Path = "C:\FirstFolder;C:\SecondFolder" } }
		Mock Set-ItemProperty { }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Not -Throw

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 2 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 Expand-Archive
		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 1 Set-ItemProperty
		Assert-MockCalled -Times 1 Remove-Item
	}
}