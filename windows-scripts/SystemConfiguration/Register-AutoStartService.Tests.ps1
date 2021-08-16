. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Register-AutoStartService.ps1

}

Describe 'Register-AutoStartService' {

	It "Installs autostart service without arguments" {

		$NssmLocation = "C:\nssm.exe"
		$ServiceName = "MyService"
		$Program = "C:\MyProgram.exe"

		Mock Start-Process -ParameterFilter { ($FilePath -eq $NssmLocation) } { @{ ExitCode = 0 } }
		Mock Start-Process { throw "Invalid invocation of Start-Process" }

		Register-AutoStartService -NssmLocation $NssmLocation -ServiceName $ServiceName -Program $Program

		Assert-MockCalled Start-Process -ParameterFilter { ($FilePath -eq $NssmLocation) -and ($ArgumentList.Count -eq 3) -and ($ArgumentList[1] -eq $ServiceName)-and ($ArgumentList[2] -eq $Program) }
	}

	It "Installs autostart service with arguments" {

		$NssmLocation = "C:\nssm.exe"
		$ServiceName = "MyService"
		$Program = "C:\MyProgram.exe"
		$Arg1 = "a"
		$Arg2 = "b"

		Mock Start-Process -ParameterFilter { ($FilePath -eq $NssmLocation) } { @{ ExitCode = 0 } }
		Mock Start-Process { throw "Invalid invocation of Start-Process" }

		Register-AutoStartService -NssmLocation $NssmLocation -ServiceName $ServiceName -Program $Program -ArgumentList @($Arg1, $Arg2)

		Assert-MockCalled Start-Process -ParameterFilter { ($FilePath -eq $NssmLocation) -and ($ArgumentList[0] -eq "install") -and ($ArgumentList.Count -eq 5) -and ($ArgumentList[1] -eq $ServiceName)-and ($ArgumentList[2] -eq $Program) -and ($ArgumentList[3] -eq $Arg1) -and ($ArgumentList[4] -eq $Arg2) }
	}
}
