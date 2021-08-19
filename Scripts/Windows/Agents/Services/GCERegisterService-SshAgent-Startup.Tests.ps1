. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\..\SystemConfiguration\Register-AutoStartService.ps1
	. ${PSScriptRoot}\GCERegisterService-SshAgent-Startup.ps1
}

Describe 'GCERegisterService-SshAgent-Startup' {

	It "Fails if Resolve-Path fails" {

		Mock Resolve-Path { throw "Resolve-Path failed" }
		Mock Register-AutoStartService { throw "Register-AutoStartService should not be called" }

		{ GCERegisterService-SshAgent-Startup } |
			Should -Throw

		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 0 Register-AutoStartService
	}

	It "Fails if register-service fails" {

		Mock Resolve-Path { }
		Mock Register-AutoStartService { throw "Register-AutoStartService failed" }

		{ GCERegisterService-SshAgent-Startup } |
			Should -Throw

		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Register-AutoStartService
	}

	It "Succeeds if register-service succeeds" {

		Mock Resolve-Path { }
		Mock Register-AutoStartService { }

		{ GCERegisterService-SshAgent-Startup } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Register-AutoStartService
	}

	It "Succeeds only if Register-AutoStartService is called with a valid script location" {

		Mock Resolve-Path { if (!(Test-Path $Path)) { throw "Path must point to an existing script; ${Path} is not valid" } }
		Mock Register-AutoStartService { }

		{ GCERegisterService-SshAgent-Startup } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 1 Resolve-Path
		Assert-MockCalled -Exactly -Times 1 Register-AutoStartService
	}
}