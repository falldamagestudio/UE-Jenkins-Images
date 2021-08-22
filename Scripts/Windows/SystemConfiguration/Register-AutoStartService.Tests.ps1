. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Register-AutoStartService.ps1

}

Describe 'Register-AutoStartService' {

	It "Installs autostart service without arguments" {

		$ServiceName = "MyService"
		$Program = "C:\MyProgram.exe"

		Mock Start-Process -ParameterFilter { $ArgumentList[0] -eq "install" } {
			$ArgumentList.Count | Should -Be 3
			$ArgumentList[1] | Should -Be $ServiceName
			$ArgumentList[2] | Should -Be $Program
			@{ ExitCode = 0 }
		}
		Mock Start-Process { throw "Invalid invocation of Start-Process" }

		Register-AutoStartService -ServiceName $ServiceName -Program $Program

		Assert-MockCalled -Exactly -Times 1 Start-Process
	}

	It "Installs autostart service with arguments" {

		$ServiceName = "MyService"
		$Program = "C:\MyProgram.exe"
		$Arg1 = "a"
		$Arg2 = "b"

		Mock Start-Process -ParameterFilter { $ArgumentList[0] -eq "install" } {
			$ArgumentList.Count | Should -Be 5
			$ArgumentList[1] | Should -Be $ServiceName
			$ArgumentList[2] | Should -Be $Program
			$ArgumentList[3] | Should -Be $Arg1
			$ArgumentList[4] | Should -Be $Arg2
			@{ ExitCode = 0 }
		}
		Mock Start-Process { throw "Invalid invocation of Start-Process" }

		Register-AutoStartService -ServiceName $ServiceName -Program $Program -ArgumentList @($Arg1, $Arg2)

		Assert-MockCalled -Exactly -Times 1 Start-Process
	}

	It "Installs autostart service with non-SYSTEM credential" {

		$ServiceName = "MyService"
		$Program = "C:\MyProgram.exe"

		$ComputerName = "TestComputer"
		$UserName = "TestUser"
		$Password = "1234"		
		$SecureStringPassword = ConvertTo-SecureString $Password -AsPlainText -Force -ErrorAction Stop
		$Credential = New-Object System.Management.Automation.PSCredential("${ComputerName}\${UserName}", $SecureStringPassword)

		Mock Start-Process -ParameterFilter { $ArgumentList[0] -eq "install" } {
			$ArgumentList.Count | Should -Be 3
			$ArgumentList[1] | Should -Be $ServiceName
			$ArgumentList[2] | Should -Be $Program
			@{ ExitCode = 0 }
		}
		Mock Start-Process -ParameterFilter { $ArgumentList[0] -eq "set" } {
			$ArgumentList.Count | Should -Be 5
			$ArgumentList[1] | Should -Be $ServiceName
			$ArgumentList[2] | Should -Be "ObjectName"
			$ArgumentList[3] | Should -Be "${ComputerName}\${UserName}"
			$ArgumentList[4] | Should -Be $Password
			@{ ExitCode = 0 }
		}
		Mock Start-Process { throw "Invalid invocation of Start-Process" }

		Register-AutoStartService -ServiceName $ServiceName -Program $Program -Credential $Credential

		Assert-MockCalled -Exactly -Times 2 Start-Process
	}

}
