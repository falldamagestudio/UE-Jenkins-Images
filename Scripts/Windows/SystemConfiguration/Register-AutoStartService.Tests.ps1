. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Register-AutoStartService.ps1

}

Describe 'Register-AutoStartService' {

	It "Installs autostart service without arguments" {

		$ServiceName = "MyService"
		$Program = "C:\MyProgram.exe"

		Mock Start-Process { @{ ExitCode = 0 } }

		Register-AutoStartService -ServiceName $ServiceName -Program $Program

		Assert-MockCalled Start-Process -ParameterFilter { ($ArgumentList.Count -eq 3) -and ($ArgumentList[1] -eq $ServiceName)-and ($ArgumentList[2] -eq $Program) }
	}

	It "Installs autostart service with arguments" {

		$ServiceName = "MyService"
		$Program = "C:\MyProgram.exe"
		$Arg1 = "a"
		$Arg2 = "b"

		Mock Start-Process { @{ ExitCode = 0 } }

		Register-AutoStartService -ServiceName $ServiceName -Program $Program -ArgumentList @($Arg1, $Arg2)

		Assert-MockCalled Start-Process -ParameterFilter { ($ArgumentList[0] -eq "install") -and ($ArgumentList.Count -eq 5) -and ($ArgumentList[1] -eq $ServiceName)-and ($ArgumentList[2] -eq $Program) -and ($ArgumentList[3] -eq $Arg1) -and ($ArgumentList[4] -eq $Arg2) }
	}
}
