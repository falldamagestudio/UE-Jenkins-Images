
Describe 'VerifyInstance' {

	It "Has Win32 Long Paths enabled" {
		$LongPathsEnabled = (Get-ItemProperty -path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -name "LongPathsEnabled").LongPathsEnabled
		$LongPathsEnabled | Should Not Be 0
	}

	It "Has Jenkins Agent registered as a service" {
		$Service = Get-Service "JenkinsAgent"
		$Service | Should Not Be $null
	}

	It "Has the Logging Agent registered as a service" {

		# The Logging Agent's installer is asynchronous.
		# We give it this much time to complete installation in the background, before we declare failure.
		$MaxTries = 15
		
		for ($Try = 0; $Try -lt $MaxTries; $Try++) {
			$Service = Get-Service "StackdriverLogging"
			if ($Service) {
				return
			}
			Start-Sleep 1
		}

		throw "StackdriverLogging service did now show up within ${MaxTries} seconds"
	}
}