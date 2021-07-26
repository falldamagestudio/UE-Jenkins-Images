. ${PSScriptRoot}\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Invoke-External-PrintStdout.ps1
	. ${PSScriptRoot}\Run-SshAgent.ps1

}

Describe 'Run-SshAgent' {

	It "Throws an exception if docker cannot be found" {

		Mock Invoke-External-PrintStdout { throw "Cannot find docker" }

		{ Run-SshAgent -AgentJarFolder "C:\AgentJar" -AgentJarFile "C:\AgentJar\agent.jar" -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -PlasticConfigFolder "C:\PlasticConfig" -AgentImageURL "agent-image" } |
			Should -Throw

		Assert-MockCalled -Times 1 Invoke-External-PrintStdout -ParameterFilter { $LiteralPath -eq "docker" }
	}

	It "Should throw if Docker returns a nonzero error code" {

		Mock Invoke-External-PrintStdout { 125 }

		{ Run-SshAgent -AgentJarFolder "C:\AgentJar" -AgentJarFile "C:\AgentJar\agent.jar" -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -PlasticConfigFolder "C:\PlasticConfig" -AgentImageURL "agent-image" } |
			Should -Throw

		Assert-MockCalled -Times 1 Invoke-External-PrintStdout -ParameterFilter { $LiteralPath -eq "docker" }
	}

	It "Should succeed if Docker returns a zero error code" {

		Mock Invoke-External-PrintStdout { 0 }

		{ Run-SshAgent -AgentJarFolder "C:\AgentJar" -AgentJarFile "C:\AgentJar\agent.jar" -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -PlasticConfigFolder "C:\PlasticConfig" -AgentImageURL "agent-image" } |
			Should -Not -Throw

		Assert-MockCalled -Times 3 Invoke-External-PrintStdout -ParameterFilter { $LiteralPath -eq "docker" }
	}
}