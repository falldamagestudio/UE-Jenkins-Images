. ${PSScriptRoot}\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Invoke-External.ps1
	. ${PSScriptRoot}\Register-AutoStartService.ps1

}

Describe 'Register-AutoStartService' {

	It "Installs autostart service without arguments" {

		$NssmLocation = "C:\nssm.exe"
		$ServiceName = "MyService"
		$Program = "C:\MyProgram.exe"

		Mock Invoke-External -ParameterFilter { ($LiteralPath -eq $NssmLocation) } { 0 }
		Mock Invoke-External { throw "Invalid invocation of Invoke-External" }

		Register-AutoStartService -NssmLocation $NssmLocation -ServiceName $ServiceName -Program $Program

		Assert-MockCalled Invoke-External -ParameterFilter { ($LiteralPath -eq $NssmLocation) -and (($PassThruArgs)[0] -eq "@install MyService C:\MyProgram.exe") }
	}

	It "Installs autostart service with arguments" {

		$NssmLocation = "C:\nssm.exe"
		$ServiceName = "MyService"
		$Program = "C:\MyProgram.exe"
		$Arg1 = "a"
		$Arg2 = "b"

		Mock Invoke-External -ParameterFilter { ($LiteralPath -eq $NssmLocation) } { 0 }
		Mock Invoke-External { throw "Invalid invocation of Invoke-External" }

		Register-AutoStartService -NssmLocation $NssmLocation -ServiceName $ServiceName -Program $Program -Arguments $Arg1,$Arg2

		Assert-MockCalled Invoke-External -ParameterFilter { ($LiteralPath -eq $NssmLocation) -and (($PassThruArgs)[0] -eq "@install MyService C:\MyProgram.exe a b") }
	}
}
