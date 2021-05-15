. ${PSScriptRoot}\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Get-GCESecret.ps1

}

Describe 'Get-GCESecret' {

	$Metadata = "http://metadata.google.internal/computeMetadata/v1"

	It "Throws an exception if Invoke-RestMethod cannot retrieve access token" {

		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "${Metadata}/instance/service-accounts/default/token" } { throw "Unable to retrieve access token" }
		Mock Invoke-RestMethod { throw "invalid invocation of Invoke-RestMethod: ${Uri}" }

		{ Get-GCESecret -Key "abc" } | Should -Throw "Unable to retrieve access token"

		Assert-MockCalled -Times 1 Invoke-RestMethod
	}

	It "Throws an exception if Invoke-RestMethod cannot retrieve project ID" {

		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "${Metadata}/instance/service-accounts/default/token" } { @{ access_token = "token" } }
		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "${Metadata}/project/project-id" } { throw "Unable to retrieve project ID" }
		Mock Invoke-RestMethod { throw "invalid invocation of Invoke-RestMethod: ${Uri}" }

		{ Get-GCESecret -Key "abc" } | Should -Throw "Unable to retrieve project ID"

		Assert-MockCalled -Times 2 Invoke-RestMethod
	}

	It "Returns `$null if Invoke-RestMethod throws when fetching key (internal error / permission denied / key does not exist)" {

		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "${Metadata}/instance/service-accounts/default/token" } { @{ access_token = "token" } }
		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "${Metadata}/project/project-id" } { "1234" }
		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "https://secretmanager.googleapis.com/v1/projects/1234/secrets/abc/versions/latest:access" } { throw "Error when retrieving key" }
		Mock Invoke-RestMethod { throw "invalid invocation of Invoke-RestMethod: ${Uri}" }

		Get-GCESecret -Key "abc" | Should -Be $null

		Assert-MockCalled -Times 3 Invoke-RestMethod
	}

	It "Throws an exception if the key is not a valid base64-encoded string" {

		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "${Metadata}/instance/service-accounts/default/token" } { @{ access_token = "token" } }
		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "${Metadata}/project/project-id" } { "1234" }
		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "https://secretmanager.googleapis.com/v1/projects/1234/secrets/abc/versions/latest:access" } { @{ name = "..."; payload = @{ data = "---" } } } # "---" is invalid base64 encoding
		Mock Invoke-RestMethod { throw "invalid invocation of Invoke-RestMethod: ${Uri}" }

		{ Get-GCESecret -Key "abc" } | Should -Throw

		Assert-MockCalled -Times 3 Invoke-RestMethod
	}

	It "Returns the key decoded as ASCII" {

		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "${Metadata}/instance/service-accounts/default/token" } { @{ access_token = "token" } }
		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "${Metadata}/project/project-id" } { "1234" }
		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "https://secretmanager.googleapis.com/v1/projects/1234/secrets/abc/versions/latest:access" } { @{ name = "..."; payload = @{ data = "SGVsbG8=" } } } # "SGVsbG8K" is "Hello" base64-encoded
		Mock Invoke-RestMethod { throw "invalid invocation of Invoke-RestMethod: ${Uri}" }

		Get-GCESecret -Key "abc" | Should -Be "Hello"

		Assert-MockCalled -Times 3 Invoke-RestMethod
	}

	It "Returns the key decoded as a binary string" {

		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "${Metadata}/instance/service-accounts/default/token" } { @{ access_token = "token" } }
		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "${Metadata}/project/project-id" } { "1234" }
		Mock Invoke-RestMethod -ParameterFilter { $Uri -eq "https://secretmanager.googleapis.com/v1/projects/1234/secrets/abc/versions/latest:access" } { @{ name = "..."; payload = @{ data = "SGVsbG8=" } } } # "SGVsbG8K" is "Hello" base64-encoded
		Mock Invoke-RestMethod { throw "invalid invocation of Invoke-RestMethod: ${Uri}" }

		Get-GCESecret -Key "abc" -Binary $true | Should -Be @(72, 101, 108, 108, 111)

		Assert-MockCalled -Times 3 Invoke-RestMethod
	}
}