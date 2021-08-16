. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Create-ServiceUser.ps1

}

Describe 'Create-ServiceUser' {

	It "Throws an error if it cannot create the service user" {

		Mock New-LocalUser -ParameterFilter { $Name -eq "TestUser" } { throw "Cannot create test user" }
		Mock New-LocalUser { throw "Invalid invocation of New-LocalUser" }

		Mock Set-LocalUser { throw "Set-LocalUser should not be called" }

		Mock Add-LocalGroupMember { throw "Add-LocalGroupMember should not be called" }

		{ Create-ServiceUser -Name "TestUser" } |
			Should -Throw

		Assert-MockCalled -Times 1 New-LocalUser -ParameterFilter { $Name -eq "TestUser" }
		Assert-MockCalled -Times 0 Set-LocalUser
		Assert-MockCalled -Times 0 Add-LocalGroupMember
	}

	It "Throws an error if the service user cannot be manipulated" {

		Mock New-LocalUser -ParameterFilter { $Name -eq "TestUser" } { }
		Mock New-LocalUser { throw "Invalid invocation of New-LocalUser" }

		Mock Set-LocalUser -ParameterFilter { $Name -eq "TestUser" } { throw "Cannot manipulate test user" }
		Mock Set-LocalUser { throw "Invalid invocation of Set-LocalUser" }

		Mock Add-LocalGroupMember { throw "Add-LocalGroupMember should not be called" }

		{ Create-ServiceUser -Name "TestUser" } |
			Should -Throw

		Assert-MockCalled -Times 1 New-LocalUser -ParameterFilter { $Name -eq "TestUser" }
		Assert-MockCalled -Times 1 Set-LocalUser -ParameterFilter { $Name -eq "TestUser" }
		Assert-MockCalled -Times 0 Add-LocalGroupMember
	}

	It "Throws an error if the service user cannot be added to a group" {

		Mock New-LocalUser -ParameterFilter { $Name -eq "TestUser" } { }
		Mock New-LocalUser { throw "Invalid invocation of New-LocalUser" }

		Mock Set-LocalUser -ParameterFilter { $Name -eq "TestUser" } { }
		Mock Set-LocalUser { throw "Invalid invocation of Set-LocalUser" }

		Mock Add-LocalGroupMember -ParameterFilter { "TestUser" -eq $Member } { throw "Cannot add member to group" }
		Mock Add-LocalGroupMember { throw "Invalid invocation of Add-LocalGroupMember" }

		{ Create-ServiceUser -Name "TestUser" } |
			Should -Throw

		Assert-MockCalled -Times 1 New-LocalUser -ParameterFilter { $Name -eq "TestUser" }
		Assert-MockCalled -Times 1 Set-LocalUser -ParameterFilter { $Name -eq "TestUser" }
		Assert-MockCalled -Times 1 Add-LocalGroupMember -ParameterFilter { "TestUser" -eq $Member }
	}

	It "Succeeds if user creation & configuration completes successfully" {

		Mock New-LocalUser -ParameterFilter { $Name -eq "TestUser" } { }
		Mock New-LocalUser { throw "Invalid invocation of New-LocalUser" }

		Mock Set-LocalUser -ParameterFilter { $Name -eq "TestUser" } { }
		Mock Set-LocalUser { throw "Invalid invocation of Set-LocalUser" }

		Mock Add-LocalGroupMember -ParameterFilter { "TestUser" -eq $Member } { }
		Mock Add-LocalGroupMember { throw "Invalid invocation of Add-LocalGroupMember" }

		{ Create-ServiceUser -Name "TestUser" } |
			Should -Not -Throw

		Assert-MockCalled -Times 1 New-LocalUser -ParameterFilter { $Name -eq "TestUser" }
		Assert-MockCalled -Times 1 Set-LocalUser -ParameterFilter { $Name -eq "TestUser" }
		Assert-MockCalled -Times 1 Add-LocalGroupMember -ParameterFilter { "TestUser" -eq $Member }
	}
}
