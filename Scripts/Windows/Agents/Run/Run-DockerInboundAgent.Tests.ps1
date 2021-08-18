. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Run-DockerAgent.ps1
	. ${PSScriptRoot}\Run-DockerInboundAgent.ps1

}

Describe 'Run-DockerInboundAgent' {

	It "Throws an exception if Run-DockerAgent fails" {

		Mock Run-Dockeragent -ParameterFilter { ($AgentImageUrl -eq "agent-image") -and ($AgentRunArguments[0] -eq "--rm") } { throw "Run-DockerAgent failed" }
		Mock Run-DockerAgent { throw "Invalid invocation of Run-DockerAgent" }

		{ Run-DockerInboundAgent -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -PlasticConfigFolder "C:\PlasticConfig" -JenkinsURL "http://jenkins" -JenkinsSecret "1234" -AgentImageURL "agent-image" -AgentName "agent" } |
			Should -Throw

		Assert-MockCalled -Times 1 -Exactly Run-Dockeragent -ParameterFilter { ($AgentImageUrl -eq "agent-image") -and ($AgentRunArguments[0] -eq "--rm") }
		Assert-MockCalled -Times 1 -Exactly Run-DockerAgent
	}

	It "Succeeds if Run-DockerAgent succeeds" {

		Mock Run-Dockeragent -ParameterFilter { ($AgentImageUrl -eq "agent-image") -and ($AgentRunArguments[0] -eq "--rm") } { }
		Mock Run-DockerAgent { throw "Invalid invocation of Run-DockerAgent" }

		{ Run-DockerInboundAgent -JenkinsAgentFolder "C:\JenkinsAgent" -JenkinsWorkspaceFolder "C:\JenkinsWorkspace" -PlasticConfigFolder "C:\PlasticConfig" -JenkinsURL "http://jenkins" -JenkinsSecret "1234" -AgentImageURL "agent-image" -AgentName "agent" } |
			Should -Not -Throw

		Assert-MockCalled -Times 1 -Exactly Run-Dockeragent -ParameterFilter { ($AgentImageUrl -eq "agent-image") -and ($AgentRunArguments[0] -eq "--rm") }
		Assert-MockCalled -Times 1 -Exactly Run-DockerAgent
	}
}