. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Run-DockerAgent.ps1
	. ${PSScriptRoot}\Run-DockerSwarmAgent.ps1

}

Describe 'Run-DockerSwarmAgent' {

	It "Throws an exception if Run-DockerAgent fails" {

		Mock Run-Dockeragent -ParameterFilter { ($AgentImageUrl -eq "agent-image") -and ($AgentRunArguments[0] -eq "--rm") } { throw "Run-DockerAgent failed" }
		Mock Run-DockerAgent { throw "Invalid invocation of Run-DockerAgent" }

		{ Run-DockerSwarmAgent -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -PlasticConfigFolder "C:\PlasticConfig" -JenkinsURL "http://jenkins" -AgentUsername "admin@example.com" -AgentAPIToken "1234" -AgentImageURL "agent-image" -NumExecutors 1 -Labels "lab1 lab2 lab3" -AgentName "agent" } |
			Should -Throw

		Assert-MockCalled -Times 1 -Exactly Run-Dockeragent -ParameterFilter { ($AgentImageUrl -eq "agent-image") -and ($AgentRunArguments[0] -eq "--rm") }
		Assert-MockCalled -Times 1 -Exactly Run-DockerAgent
	}

	It "Succeeds if Run-DockerAgent succeeds" {

		Mock Run-Dockeragent -ParameterFilter { ($AgentImageUrl -eq "agent-image") -and ($AgentRunArguments[0] -eq "--rm") } { }
		Mock Run-DockerAgent { throw "Invalid invocation of Run-DockerAgent" }

		{ Run-DockerSwarmAgent -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -PlasticConfigFolder "C:\PlasticConfig" -JenkinsURL "http://jenkins" -AgentUsername "admin@example.com" -AgentAPIToken "1234" -AgentImageURL "agent-image" -NumExecutors 1 -Labels "lab1 lab2 lab3" -AgentName "agent" } |
			Should -Not -Throw

		Assert-MockCalled -Times 1 -Exactly Run-Dockeragent -ParameterFilter { ($AgentImageUrl -eq "agent-image") -and ($AgentRunArguments[0] -eq "--rm") }
		Assert-MockCalled -Times 1 -Exactly Run-DockerAgent
	}
}