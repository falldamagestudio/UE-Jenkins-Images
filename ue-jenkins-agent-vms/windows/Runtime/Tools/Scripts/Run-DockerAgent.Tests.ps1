. ${PSScriptRoot}\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Invoke-External-Command.ps1
	. ${PSScriptRoot}\Run-DockerAgent.ps1

}

Describe 'Run-DockerAgent' {

	It "Throws an exception if docker cannot be found" {

		Mock Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "pull") } { throw "Cannot find docker" }
		Mock Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "run") } { throw "Invoke-External-Command 'docker' 'run' should not be called" }
		Mock Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "stop") } { }
		Mock Invoke-External-Command { throw "Invalid invocation of Invoke-External-Command" }

		{ Run-DockerAgent -AgentImageURL "agent-image" -AgentRunArguments @("--rm", "--name", "test-agent", "agent-image") } |
			Should -Throw

		Assert-MockCalled -Times 1 -Exactly Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "pull") }
		Assert-MockCalled -Times 0 -Exactly Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "run") }
		Assert-MockCalled -Times 1 -Exactly Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "stop") }
		Assert-MockCalled -Times 2 -Exactly Invoke-External-Command
	}

	It "Should throw if Docker pull returns a nonzero error code" {

		Mock Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "pull") } { $ExitCode.Value = 125 }
		Mock Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "run") } { throw "Invoke-External-Command 'docker' 'run' should not be called" }
		Mock Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "stop") } { }
		Mock Invoke-External-Command { throw "Invoke-External-Command should not be called" }

		{ Run-DockerAgent -AgentImageURL "agent-image" -AgentRunArguments @("--rm", "--name", "test-agent", "agent-image") } |
			Should -Throw

		Assert-MockCalled -Times 1 -Exactly Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "pull") }
		Assert-MockCalled -Times 0 -Exactly Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "run") }
		Assert-MockCalled -Times 1 -Exactly Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "stop") }
		Assert-MockCalled -Times 2 -Exactly Invoke-External-Command
	}

	It "Should throw if Docker run returns a nonzero error code" {

		Mock Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "pull") } { $ExitCode.Value = 0 }
		Mock Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "run") } { $ExitCode.Value = 125; throw "Invoke-External-Command 'docker' 'run' should not be called" }
		Mock Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "stop") } { }
		Mock Invoke-External-Command { throw "Invoke-External-Command should not be called" }

		{ Run-DockerAgent -AgentImageURL "agent-image" -AgentRunArguments @("--rm", "--name", "test-agent", "agent-image") } |
			Should -Throw

		Assert-MockCalled -Times 1 -Exactly Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "pull") }
		Assert-MockCalled -Times 1 -Exactly Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "run") }
		Assert-MockCalled -Times 1 -Exactly Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "stop") }
		Assert-MockCalled -Times 3 -Exactly Invoke-External-Command
	}

	It "Should succeed if Docker run returns a zero error code" {

		Mock Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "pull") } { $ExitCode.Value = 0 }
		Mock Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "run") } { $ExitCode.Value = 0 }
		Mock Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "stop") } { }
		Mock Invoke-External-Command { throw "Invoke-External-Command should not be called" }

		{ Run-DockerAgent -AgentImageURL "agent-image" -AgentRunArguments @("--rm", "--name", "test-agent", "agent-image") } |
			Should -Not -Throw

		Assert-MockCalled -Times 1 -Exactly Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "pull") }
		Assert-MockCalled -Times 1 -Exactly Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "run") }
		Assert-MockCalled -Times 1 -Exactly Invoke-External-Command -ParameterFilter { ($LiteralPath -eq "docker") -and ($ArgumentList[0] -eq "stop") }
		Assert-MockCalled -Times 3 -Exactly Invoke-External-Command
	}
}