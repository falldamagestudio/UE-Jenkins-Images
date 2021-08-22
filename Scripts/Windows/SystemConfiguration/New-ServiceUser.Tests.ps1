. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\New-ServiceUser.ps1

}

Describe 'New-ServiceUser' {

	It "Throws an error if it cannot generate a password" {

		Mock New-RandomPassword { throw "New-RandomPassword failed" }
		Mock New-Profile { throw "New-Profile shold not be called" }
		Mock ConvertTo-SecureString { throw "ConvertTo-SecureString shold not be called" }

		{ New-ServiceUser -Name "TestUser" } |
			Should -Throw "New-RandomPassword failed"

		Assert-MockCalled -Exactly -Times 1 New-RandomPassword
		Assert-MockCalled -Exactly -Times 0 New-Profile
		Assert-MockCalled -Exactly -Times 0 ConvertTo-SecureString
	}

	It "Returns an appropriate credential object when successful" {

		$UserName = "TestUser"
		$Password = "1234"

		Mock New-RandomPassword { $Password }
		Mock New-Profile { }
		Mock Add-LocalGroupMember { }

		$Credential = New-ServiceUser -Name $UserName

		$Credential.Username | Should -Be "${env:COMPUTERNAME}\${UserName}"
		$Credential.GetNetworkCredential().UserName | Should -Be $UserName
		$Credential.GetNetworkCredential().Password | Should -Be $Password

		Assert-MockCalled -Exactly -Times 1 New-RandomPassword
		Assert-MockCalled -Exactly -Times 1 New-Profile
		Assert-MockCalled -Exactly -Times 1 Add-LocalGroupMember
	}
}
