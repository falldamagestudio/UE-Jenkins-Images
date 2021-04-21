. ${PSScriptRoot}\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Register-AutoStartService.ps1

}

Describe 'Register-AutoStartService' {

	It "Installs autostart service without arguments" {

		$NssmLocation = "C:\nssm.exe"
		$ServiceName = "MyService"
		$Program = "C:\MyProgram.exe"

		Mock Start-Process { }

		Register-AutoStartService -NssmLocation $NssmLocation -ServiceName $ServiceName -Program $Program

		Assert-MockCalled Start-Process -ParameterFilter { ($FilePath -eq $NssmLocation) -and $ArgumentList.Contains($ServiceName) -and $ArgumentList.Contains($Program) }
	}

	It "Installs autostart service with arguments" {

		$NssmLocation = "C:\nssm.exe"
		$ServiceName = "MyService"
		$Program = "C:\MyProgram.exe"
		$Arg1 = "a"
		$Arg2 = "b"

		Mock Start-Process { }

		Register-AutoStartService -NssmLocation $NssmLocation -ServiceName $ServiceName -Program $Program -Arguments $Arg1,$Arg2

		Assert-MockCalled Start-Process -ParameterFilter { ($FilePath -eq $NssmLocation) -and $ArgumentList.Contains($ServiceName) -and $ArgumentList.Contains($Program) -and $ArgumentList.Contains($Arg1) -and $ArgumentList.Contains($Arg2)}
	}
}
