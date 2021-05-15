. ${PSScriptRoot}\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Invoke-External-PrintStdout.ps1
	. ${PSScriptRoot}\Run-SwarmAgent.ps1

}

Describe 'Run-SwarmAgent' {

	It "Throws an exception if docker cannot be found" {

		Mock Invoke-External-PrintStdout { throw "Cannot find docker" }

		{ Run-SwarmAgent -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -PlasticConfigFolder "C:\PlasticConfig" -JenkinsURL "http://jenkins" -AgentUsername "admin@example.com" -AgentAPIToken "1234" -AgentImageURL "agent-image" -AgentName "agent" } |
			Should -Throw

		Assert-MockCalled -Times 1 Invoke-External-PrintStdout -ParameterFilter { $LiteralPath -eq "docker" }
	}

	It "Should throw if Docker returns a nonzero error code" {

		Mock Invoke-External-PrintStdout { 125 }

		{ Run-SwarmAgent -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -PlasticConfigFolder "C:\PlasticConfig" -JenkinsURL "http://jenkins" -AgentUsername "admin@example.com" -AgentAPIToken "1234" -AgentImageURL "agent-image" -AgentName "agent" } |
			Should -Throw

		Assert-MockCalled -Times 1 Invoke-External-PrintStdout -ParameterFilter { $LiteralPath -eq "docker" }
	}

	It "Should succeed if Docker returns a zero error code" {

		Mock Invoke-External-PrintStdout { 0 }

		{ Run-SwarmAgent -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -PlasticConfigFolder "C:\PlasticConfig" -JenkinsURL "http://jenkins" -AgentUsername "admin@example.com" -AgentAPIToken "1234" -AgentImageURL "agent-image" -AgentName "agent" } |
			Should -Not -Throw

		Assert-MockCalled -Times 3 Invoke-External-PrintStdout -ParameterFilter { $LiteralPath -eq "docker" }
	}
}