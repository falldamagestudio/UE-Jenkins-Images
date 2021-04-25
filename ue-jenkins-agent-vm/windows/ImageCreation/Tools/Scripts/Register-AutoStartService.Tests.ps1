. ${PSScriptRoot}\Ensure-TestToolVersions.ps1

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

		Assert-MockCalled Start-Process -ParameterFilter { ($FilePath -eq $NssmLocation) }
	}

	It "Installs autostart service with arguments" {

		$NssmLocation = "C:\nssm.exe"
		$ServiceName = "MyService"
		$Program = "C:\MyProgram.exe"
		$Arg1 = "a"
		$Arg2 = "b"

		Mock Start-Process -ParameterFilter { ($FilePath -eq $NssmLocation) } { @{ ExitCode = 0 } }
		Mock Start-Process { throw "Invalid invocation of Start-Process" }

		Register-AutoStartService -NssmLocation $NssmLocation -ServiceName $ServiceName -Program $Program -Arguments $Arg1,$Arg2

		Assert-MockCalled Start-Process -ParameterFilter { ($FilePath -eq $NssmLocation) }
	}
}
