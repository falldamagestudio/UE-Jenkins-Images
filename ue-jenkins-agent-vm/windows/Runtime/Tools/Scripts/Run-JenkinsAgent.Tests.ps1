. ${PSScriptRoot}\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Run-JenkinsAgent.ps1

}

Describe 'Run-JenkinsAgent' {

	It "Throws an exception if docker cannot be found" {

		Mock Start-Process { throw "Cannot find docker" }

		{ Run-JenkinsAgent -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -JenkinsURL "http://jenkins" -JenkinsSecret "1234" -AgentImageURL "agent-image" -AgentName "agent" } |
			Should -Throw

		Assert-MockCalled -Times 1 Start-Process -ParameterFilter { $FilePath -eq "docker" }
	}

	It "Should throw if Docker returns a nonzero error code" {

		Mock Start-Process { @{ ExitCode = 125 } }

		{ Run-JenkinsAgent -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -JenkinsURL "http://jenkins" -JenkinsSecret "1234" -AgentImageURL "agent-image" -AgentName "agent" } |
			Should -Throw

		Assert-MockCalled -Times 1 Start-Process -ParameterFilter { $FilePath -eq "docker" }
	}

	It "Should succeed if Docker returns a zero error code" {

		Mock Start-Process { @{ ExitCode = 0 } }

		{ Run-JenkinsAgent -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -JenkinsURL "http://jenkins" -JenkinsSecret "1234" -AgentImageURL "agent-image" -AgentName "agent" } |
			Should -Not -Throw

		Assert-MockCalled -Times 3 Start-Process -ParameterFilter { $FilePath -eq "docker" }
	}
}