
Describe 'VerifyInstance' {

	It "Has Win32 Long Paths enabled" {
		$LongPathsEnabled = (Get-ItemProperty -path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -name "LongPathsEnabled").LongPathsEnabled
		$LongPathsEnabled | Should Not Be 0
	}

	It "Has Jenkins Agent registered as a service" {
		$Service = Get-Service "JenkinsAgent"
		$Service | Should Not Be $null
	}
}