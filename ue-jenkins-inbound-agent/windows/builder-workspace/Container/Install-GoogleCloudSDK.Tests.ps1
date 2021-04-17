. ${PSScriptRoot}\..\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-GoogleCloudSDK.ps1

}

Describe 'Install-GoogleCloudSDK' {

	It "Reports error if temp folder cannot be created" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { throw "NewItem cannot be created for temp folder" }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { throw "First Join-Path failed" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

        Mock Expand-Archive { throw "expand-archive failed" }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files\google-cloud-sdk" } { throw "Second Join-Path failed" }

		Mock Start-Process { throw "Start-Process failed" }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Throw "NewItem cannot be created for temp folder"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 0 Join-Path
		Assert-MockCalled -Times 0 Invoke-WebRequest
		Assert-MockCalled -Times 0 Expand-Archive
		Assert-MockCalled -Times 0 Start-Process
	}

	It "Reports error if first Join-Path fails, and removes temp folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { throw "First Join-Path failed" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

        Mock Expand-Archive { throw "expand-archive failed" }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files\google-cloud-sdk" } { throw "Second Join-Path failed" }

		Mock Start-Process { throw "Start-Process failed" }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Throw "First Join-Path failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 0 Invoke-WebRequest
		Assert-MockCalled -Times 0 Expand-Archive
		Assert-MockCalled -Times 0 Start-Process
		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports error if Invoke-WebRequest fails, and removes temp folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { return "C:\Temp\google-cloud-sdk.zip" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest failed" }

        Mock Expand-Archive { throw "expand-archive failed" }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files\google-cloud-sdk" } { throw "Second Join-Path failed" }

		Mock Start-Process { throw "Start-Process failed" }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Throw "Invoke-WebRequest failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 0 Expand-Archive
		Assert-MockCalled -Times 0 Start-Process
		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports error if Expand-Archive fails, and removes temp folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { return "C:\Temp\google-cloud-sdk.zip" }

		Mock Invoke-WebRequest { }

        Mock Expand-Archive { throw "Expand-Archive failed" }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files\google-cloud-sdk" } { throw "Second Join-Path failed" }

		Mock Start-Process { throw "Start-Process failed" }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Throw "Expand-Archive failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 Expand-Archive
		Assert-MockCalled -Times 0 Start-Process
		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports error if second Join-Path fails, and removes temp folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { return "C:\Temp\google-cloud-sdk.zip" }

		Mock Invoke-WebRequest { }

        Mock Expand-Archive { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files\google-cloud-sdk" } { throw "Second Join-Path failed" }

		Mock Start-Process { throw "Start-Process failed" }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Throw "Second Join-Path failed"

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 2 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 Expand-Archive
		Assert-MockCalled -Times 0 Start-Process
		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports error if Start-Process returns nonzero, and removes temp folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { return "C:\Temp\google-cloud-sdk.zip" }

		Mock Invoke-WebRequest { }

        Mock Expand-Archive { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files\google-cloud-sdk" } { return "C:\Program Files\google-cloud-sdk\install.bat" }

		Mock Start-Process { @{ ExitCode = 1234 } }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Throw

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 2 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 Expand-Archive
		Assert-MockCalled -Times 1 Start-Process
		Assert-MockCalled -Times 1 Remove-Item
	}

	It "Reports success if Start-Process returns zero, and removes temp folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Temp" } { return "C:\Temp\google-cloud-sdk.zip" }

		Mock Invoke-WebRequest { }

        Mock Expand-Archive { }

		Mock Join-Path -ParameterFilter { $Path -eq "C:\Program Files\google-cloud-sdk" } { return "C:\Program Files\google-cloud-sdk\install.bat" }

		Mock Start-Process { @{ ExitCode = 0 } }

		Mock Join-Path { throw "Join-Path called with wrong arguments" }

		Mock Remove-Item { }

		{ Install-GoogleCloudSDK } |
			Should -Not -Throw

		Assert-MockCalled -Times 1 New-Item
		Assert-MockCalled -Times 2 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest
		Assert-MockCalled -Times 1 Expand-Archive
		Assert-MockCalled -Times 1 Start-Process
		Assert-MockCalled -Times 1 Remove-Item
	}
}