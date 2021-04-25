. ${PSScriptRoot}\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Invoke-External.ps1
	. ${PSScriptRoot}\Run-JenkinsAgent.ps1

}

Describe 'Run-JenkinsAgent' {

	It "Throws an exception if docker cannot be found" {

		Mock Invoke-External { throw "Cannot find docker" }

		{ Run-JenkinsAgent -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -JenkinsURL "http://jenkins" -JenkinsSecret "1234" -AgentImageURL "agent-image" -AgentName "agent" } |
			Should -Throw

		Assert-MockCalled -Times 1 Invoke-External -ParameterFilter { $LiteralPath -eq "docker" }
	}

	It "Should throw if Docker returns a nonzero error code" {

		Mock Invoke-External { 125 }

		{ Run-JenkinsAgent -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -JenkinsURL "http://jenkins" -JenkinsSecret "1234" -AgentImageURL "agent-image" -AgentName "agent" } |
			Should -Throw

		Assert-MockCalled -Times 1 Invoke-External -ParameterFilter { $LiteralPath -eq "docker" }
	}

	It "Should succeed if Docker returns a zero error code" {

		Mock Invoke-External { 0 }

		{ Run-JenkinsAgent -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -JenkinsURL "http://jenkins" -JenkinsSecret "1234" -AgentImageURL "agent-image" -AgentName "agent" } |
			Should -Not -Throw

		Assert-MockCalled -Times 3 Invoke-External -ParameterFilter { $LiteralPath -eq "docker" }
	}
}