. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Install-GCELoggingAgentSource-JenkinsAgentRemoting.ps1

}

Describe 'Install-GCELoggingAgentSource-JenkinsAgentRemoting' {

	It "Throws an error if it cannot read Logging Agent's installation folder registry key" {

		Mock Get-ItemProperty { throw "Cannot read installation key" } 

		Mock Split-Path { throw "Split-path should not be called" }

		Mock Get-Content { throw "Get-Content should not be called" }

		Mock Out-File { throw "Out-File should not be called" }

		{ Install-GCELoggingAgentSource-JenkinsAgentRemoting -JenkinsAgentFolder "C:\J" } |
			Should -Throw

		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 0 Split-Path
		Assert-MockCalled -Times 0 Get-Content
		Assert-MockCalled -Times 0 Out-File
	}

	It "Throws an error if the Logging Agent's installation folder registry key does not contain uninstall info" {

		Mock Get-ItemProperty { @{ } } 

		Mock Split-Path { throw "Split-path should not be called" }

		Mock Get-Content { throw "Get-Content should not be called" }

		Mock Out-File { throw "Out-File should not be called" }

		{ Install-GCELoggingAgentSource-JenkinsAgentRemoting -JenkinsAgentFolder "C:\J" } |
			Should -Throw

		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 0 Split-Path
		Assert-MockCalled -Times 0 Get-Content
		Assert-MockCalled -Times 0 Out-File
	}

	It "Throws an error if the Logging Agent's installation folder registry key does not contain a well-formed uninstalltion path" {

		Mock Get-ItemProperty { @{ UninstallString = "blah" } } 

		Mock Split-Path { throw "Split-Path failed" }

		Mock Get-Content { throw "Get-Content should not be called" }

		Mock Out-File { throw "Out-File should not be called" }

		{ Install-GCELoggingAgentSource-JenkinsAgentRemoting -JenkinsAgentFolder "C:\J" } |
			Should -Throw

		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 1 Split-Path
		Assert-MockCalled -Times 0 Get-Content
		Assert-MockCalled -Times 0 Out-File
	}

	It "Throws an error if the config file cannot be read" {

		Mock Get-ItemProperty { @{ UninstallString = "C:\Program Files (x86)\Stackdriver Logging\uninstall.exe" } } 

		Mock Get-Content { throw "Get-Content failed" }

		Mock Out-File { throw "Out-File should not be called" }

		{ Install-GCELoggingAgentSource-JenkinsAgentRemoting -JenkinsAgentFolder "C:\J" } |
			Should -Throw

		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 1 Get-Content
		Assert-MockCalled -Times 0 Out-File
	}

	It "Throws an error if the output file cannot be written properly" {

		Mock Get-ItemProperty { @{ UninstallString = "C:\Program Files (x86)\Stackdriver Logging\uninstall.exe" } } 

		Mock Get-Content {
@"
<source>
	@type tail

	format none

	# Paths with wildcards need to use forward slashes rather than backslashes on Windows, according to https://docs.fluentd.org/input/tail#wildcard-pattern-in-path-does-not-work-on-windows-why
	# If the Jenkins Agent directory is C:\J, then this should result in a line like:
	# path 'C:/J/remoting/remoting.log.0'
	path '[JENKINS_AGENT_FOLDER_WITH_FORWARD_SLASHES]/remoting/logs/remoting.log.0'

	# This assumes that the Stackdriver Logging Agent has been installed to its default location
	# If the Stackdriver Logging agent has been installed into its default location, then this should result in a line like:
	# pos_file 'C:\Program Files (x86)\Stackdriver\LoggingAgent\Main\pos\github-actions-runner.pos'
	pos_file '[STACKDRIVER_LOGGING_AGENT_INSTALL_FOLDER]\Main\pos\github-actions-runner.pos'

	read_from_head true

	tag jenkins-agent-remoting
</source>
"@
		}

		Mock Out-File { throw "Out-File failed" }

		{ Install-GCELoggingAgentSource-JenkinsAgentRemoting -JenkinsAgentFolder "C:\J" } |
			Should -Throw

		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 1 Get-Content
		Assert-MockCalled -Times 1 Out-File
	}

	It "Succeeds if all steps succeed, and the real config file's [] placeholders get repplaced with real paths" {

		Mock Get-ItemProperty { @{ UninstallString = "C:\Program Files (x86)\Stackdriver Logging\uninstall.exe" } } 

		$script:OutFileResults = @()

		Mock Out-File { $script:OutFileResults += $PSItem }

		{ Install-GCELoggingAgentSource-JenkinsAgentRemoting -JenkinsAgentFolder "C:\J" } |
			Should -Not -Throw

		Assert-MockCalled -Times 1 Get-ItemProperty
		Assert-MockCalled -Times 1 Out-File

		$OutFileResults | Should -Contain "  path 'C:/J/remoting/logs/remoting.log.0'"
		$OutFileResults | Should -Contain "  pos_file 'C:\Program Files (x86)\Stackdriver Logging\Main\pos\jenkins-agent-remoting.pos'"
	}
}
