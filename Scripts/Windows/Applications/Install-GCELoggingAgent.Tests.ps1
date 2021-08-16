. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-GCELoggingAgent.ps1

}

Describe 'Install-GCELoggingAgent' {

	It "Throws an error if it cannot create the temp folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { throw "Cannot create temp folder" }
		Mock New-Item { throw "Invalid invocation of New-Item" }

		Mock Join-Path { throw "Join-Path should not be called" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest should not be called" }

		Mock Start-Process { throw "Start-Process should not be called" }

		Mock Remove-Item { throw "Remove-Item should not be called" }

		{ Install-GCELoggingAgent } |
			Should -Throw

		Assert-MockCalled -Times 1 New-Item -ParameterFilter { $Path -eq "C:\Temp" }
		Assert-MockCalled -Times 0 Join-Path
		Assert-MockCalled -Times 0 Invoke-WebRequest
		Assert-MockCalled -Times 0 Start-Process
		Assert-MockCalled -Times 0 Remove-Item
	}

	It "Throws an error if Join-Path fails, and removes tmep folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }
		Mock New-Item { throw "Invalid invocation of New-Item" }

		Mock Join-Path { throw "Join-Path failed" }

		Mock Invoke-WebRequest { throw "Invoke-WebRequest should not be called" }

		Mock Start-Process { throw "Start-Process should not be called" }

		Mock Remove-Item -ParameterFilter { $Path -eq "C:\Temp" } { }
		Mock Remove-Item { throw "Invalid invocation of Remove-Item" }

		{ Install-GCELoggingAgent } |
			Should -Throw

		Assert-MockCalled -Times 1 New-Item -ParameterFilter { $Path -eq "C:\Temp" }
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 0 Invoke-WebRequest
		Assert-MockCalled -Times 0 Start-Process
		Assert-MockCalled -Times 1 Remove-Item -ParameterFilter { $Path -eq "C:\Temp" }
	}

	It "Throws an error if Invoke-WebRequest fails, and removes tmep folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }
		Mock New-Item { throw "Invalid invocation of New-Item" }

		Mock Join-Path { "C:\Temp\LoggingAgent.exe" }

		Mock Invoke-WebRequest -ParameterFilter { $OutFile -eq "C:\Temp\LoggingAgent.exe" } { throw "Invoke-WebRequest failed" }
		Mock Invoke-WebRequest { throw "Invalid invocation of Invoke-WebRequest" }

		Mock Start-Process { throw "Start-Process should not be called" }

		Mock Remove-Item -ParameterFilter { $Path -eq "C:\Temp" } { }
		Mock Remove-Item { throw "Invalid invocation of Remove-Item" }

		{ Install-GCELoggingAgent } |
			Should -Throw

		Assert-MockCalled -Times 1 New-Item -ParameterFilter { $Path -eq "C:\Temp" }
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest -ParameterFilter { $OutFile -eq "C:\Temp\LoggingAgent.exe" }
		Assert-MockCalled -Times 0 Start-Process
		Assert-MockCalled -Times 1 Remove-Item -ParameterFilter { $Path -eq "C:\Temp" }
	}

	It "Throws an error if Start-Process fails, and removes tmep folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }
		Mock New-Item { throw "Invalid invocation of New-Item" }

		Mock Join-Path { "C:\Temp\LoggingAgent.exe" }

		Mock Invoke-WebRequest -ParameterFilter { $OutFile -eq "C:\Temp\LoggingAgent.exe" } { }
		Mock Invoke-WebRequest { throw "Invalid invocation of Invoke-WebRequest" }

		Mock Start-Process -ParameterFilter { $FilePath -eq "C:\Temp\LoggingAgent.exe" } { throw "Start-Process failed" }
		Mock Start-Process { throw "Invalid invocation of Start-Process" }

		Mock Remove-Item -ParameterFilter { $Path -eq "C:\Temp" } { }
		Mock Remove-Item { throw "Invalid invocation of Remove-Item" }

		{ Install-GCELoggingAgent } |
			Should -Throw

		Assert-MockCalled -Times 1 New-Item -ParameterFilter { $Path -eq "C:\Temp" }
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest -ParameterFilter { $OutFile -eq "C:\Temp\LoggingAgent.exe" }
		Assert-MockCalled -Times 1 Start-Process -ParameterFilter { $FilePath -eq "C:\Temp\LoggingAgent.exe" }
		Assert-MockCalled -Times 1 Remove-Item -ParameterFilter { $Path -eq "C:\Temp" }
	}

	It "Throws an error if Start-Process returns nonzero, and removes tmep folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }
		Mock New-Item { throw "Invalid invocation of New-Item" }

		Mock Join-Path { "C:\Temp\LoggingAgent.exe" }

		Mock Invoke-WebRequest -ParameterFilter { $OutFile -eq "C:\Temp\LoggingAgent.exe" } { }
		Mock Invoke-WebRequest { throw "Invalid invocation of Invoke-WebRequest" }

		Mock Start-Process -ParameterFilter { $FilePath -eq "C:\Temp\LoggingAgent.exe" } { @{ ExitCode = 1234 } }
		Mock Start-Process { throw "Invalid invocation of Start-Process" }

		Mock Remove-Item -ParameterFilter { $Path -eq "C:\Temp" } { }
		Mock Remove-Item { throw "Invalid invocation of Remove-Item" }

		{ Install-GCELoggingAgent } |
			Should -Throw

		Assert-MockCalled -Times 1 New-Item -ParameterFilter { $Path -eq "C:\Temp" }
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest -ParameterFilter { $OutFile -eq "C:\Temp\LoggingAgent.exe" }
		Assert-MockCalled -Times 1 Start-Process -ParameterFilter { $FilePath -eq "C:\Temp\LoggingAgent.exe" }
		Assert-MockCalled -Times 1 Remove-Item -ParameterFilter { $Path -eq "C:\Temp" }
	}

	It "Succeeds if Start-Process returns zero, and removes tmep folder" {

		Mock New-Item -ParameterFilter { $Path -eq "C:\Temp" } { }
		Mock New-Item { throw "Invalid invocation of New-Item" }

		Mock Join-Path { "C:\Temp\LoggingAgent.exe" }

		Mock Invoke-WebRequest -ParameterFilter { $OutFile -eq "C:\Temp\LoggingAgent.exe" } { }
		Mock Invoke-WebRequest { throw "Invalid invocation of Invoke-WebRequest" }

		Mock Start-Process -ParameterFilter { $FilePath -eq "C:\Temp\LoggingAgent.exe" } { @{ ExitCode = 0 } }
		Mock Start-Process { throw "Invalid invocation of Start-Process" }

		Mock Remove-Item -ParameterFilter { $Path -eq "C:\Temp" } { }
		Mock Remove-Item { throw "Invalid invocation of Remove-Item" }

		{ Install-GCELoggingAgent } |
			Should -Not -Throw

		Assert-MockCalled -Times 1 New-Item -ParameterFilter { $Path -eq "C:\Temp" }
		Assert-MockCalled -Times 1 Join-Path
		Assert-MockCalled -Times 1 Invoke-WebRequest -ParameterFilter { $OutFile -eq "C:\Temp\LoggingAgent.exe" }
		Assert-MockCalled -Times 1 Start-Process -ParameterFilter { $FilePath -eq "C:\Temp\LoggingAgent.exe" }
		Assert-MockCalled -Times 1 Remove-Item -ParameterFilter { $Path -eq "C:\Temp" }
	}
}
