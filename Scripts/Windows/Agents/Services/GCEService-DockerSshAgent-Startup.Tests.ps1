. ${PSScriptRoot}\..\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\..\SystemConfiguration\Resize-PartitionToMaxSize.ps1
	. ${PSScriptRoot}\..\..\SystemConfiguration\Get-GCESecret.ps1
}

Describe 'GCEService-DockerSshAgent-Startup' {

	It "Retries settings fetch until parameters are available" {

		$PublicKeyRef = "rsa-key abcd"

		$script:LoopCount = 0
		$script:SleepCount = 0

		Mock Start-Transcript { }
		Mock Resolve-Path { "invalid path" }
		Mock Get-Date { "invalid date" }
		Mock Stop-Transcript { }

		Mock Write-Host { }

		Mock Resize-PartitionToMaxSize { }

		Mock Get-GCESecret -ParameterFilter { $Key -eq "ssh-vm-public-key-windows" } { $script:LoopCount++; if ($script:LoopCount -lt 3) { $null } else { $PublicKeyRef } }
		Mock Get-GCESecret { throw "Invalid invocation of Get-GCESecret" }

		Mock Set-Content -ParameterFilter { $Path -eq "${env:PROGRAMDATA}\ssh\administrators_authorized_keys" } { }
		Mock Set-Content { throw "Invalid invocation of Set-Content" }

		# TODO: mock 'icacls' calls somehow

		Mock Start-Service -ParameterFilter { $Name -eq "sshd" } { }
		Mock Start-Service { throw "Invalid invocation of Start-Service" }

		Mock Get-Service -ParameterFilter { $Name -eq "sshd" } { $obj = New-Object -TypeName PSObject; $obj | Add-Member -Type ScriptMethod -Name WaitForStatus -Value { param ( [string]$Status ) }; $obj }
		Mock Get-Service { throw "Invalid invocation of Get-Service" }

		Mock Start-Sleep { if ($script:SleepCount -lt 10) { $script:SleepCount++ } else { throw "Infinite loop detected when waiting for GCE secrets to be set" } }

		{ & ${PSScriptRoot}\GCEService-DockerSshAgent-Startup.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Exactly -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "ssh-vm-public-key-windows" }

		Assert-MockCalled -Exactly -Times 2 Start-Sleep

		Assert-MockCalled -Exactly -Times 1 Set-Content

		Assert-MockCalled -Exactly -Times 1 Start-Service
		Assert-MockCalled -Exactly -Times 1 Get-Service
	}
}