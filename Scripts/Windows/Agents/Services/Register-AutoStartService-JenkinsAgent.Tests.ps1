. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Register-AutoStartService-JenkinsAgent.ps1

}

Describe 'Register-AutoStartService-JenkinsAgent' {

	BeforeEach {
		$ComputerName = "TestComputer"
		$UserName = "TestUser"
		$Password = "1234"		
		$SecureStringPassword = ConvertTo-SecureString $Password -AsPlainText -Force -ErrorAction Stop
		$Credential = New-Object System.Management.Automation.PSCredential("${ComputerName}\${UserName}", $SecureStringPassword)
	}

	It "Reports an error if Test-Path fails (ie, the script does not exist)" {

		$ScriptLocation = "C:\MyScript.ps1"

		Mock Test-Path { throw "ScriptLocation does not exist" }
		Mock Register-AutoStartService { throw "Register-AutoStartService should not be called" }

		{ Register-AutoStartService-JenkinsAgent -ScriptLocation $ScriptLocation -Credential $Credential } |
			Should -Throw "ScriptLocation does not exist"

			Assert-MockCalled -Exactly -Times 1 Test-Path
			Assert-MockCalled -Exactly -Times 0 Register-AutoStartService
		}

	It "Reports an error if Register-AutoStartService fails" {

		$ScriptLocation = "C:\MyScript.ps1"

		Mock Test-Path { $true }
		Mock Register-AutoStartService { throw "Failed registering service" }

		{ Register-AutoStartService-JenkinsAgent -ScriptLocation $ScriptLocation -Credential $Credential } |
			Should -Throw "Failed registering service"

			Assert-MockCalled -Exactly -Times 1 Test-Path
			Assert-MockCalled -Exactly -Times 1 Register-AutoStartService
		}

	It "Succeeds if Register-AutoStartService succeeds" {

		$ScriptLocation = "C:\MyScript.ps1"

		Mock Test-Path { $true }
		Mock Register-AutoStartService { }

		{ Register-AutoStartService-JenkinsAgent -ScriptLocation $ScriptLocation -Credential $Credential } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Test-Path
		Assert-MockCalled -Exactly -Times 1 Register-AutoStartService
	}
}
