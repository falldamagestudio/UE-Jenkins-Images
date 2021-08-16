. ${PSScriptRoot}\..\Tools\Scripts\Ensure-TestToolVersions.ps1

BeforeAll {
	. ${PSScriptRoot}\..\Tools\Scripts\Resize-PartitionToMaxSize.ps1
	. ${PSScriptRoot}\..\Tools\Scripts\Get-GCESecret.ps1
}

Describe 'GCEService-Sshd' {

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

		Mock Get-GCESecret -ParameterFilter { $Key -eq "ssh-vm-public-key-windows" } { if ($script:LoopCount -lt 3) { $script:LoopCount++; $null } else { $PublicKeyRef } }
		Mock Get-GCESecret { throw "Invalid invocation of Get-GCESecret" }

		Mock Set-Content -ParameterFilter { $Path -eq "${env:PROGRAMDATA}\ssh\administrators_authorized_keys" } { }
		Mock Set-Content { throw "Invalid invocation of Set-Content" }

		# TODO: mock 'icacls' calls somehow

		Mock Start-Service -ParameterFilter { $Name -eq "sshd" } { }
		Mock Start-Service { throw "Invalid invocation of Start-Service" }

		Mock Get-Service -ParameterFilter { $Name -eq "sshd" } { $obj = New-Object -TypeName PSObject; $obj | Add-Member -Type ScriptMethod -Name WaitForStatus -Value { param ( [string]$Status ) }; $obj }
		Mock Get-Service { throw "Invalid invocation of Get-Service" }

		Mock Start-Sleep { if ($script:SleepCount -lt 10) { $script:SleepCount++ } else { throw "Infinite loop detected when waiting for GCE secrets to be set" } }

		{ & ${PSScriptRoot}\GCEService-Sshd.ps1 } |
			Should -Not -Throw

		Assert-MockCalled -Times 3 Get-GCESecret -ParameterFilter { $Key -eq "ssh-vm-public-key-windows" }

		Assert-MockCalled -Times 2 Start-Sleep

		Assert-MockCalled -Times 1 Set-Content

		Assert-MockCalled -Times 1 Start-Service
		Assert-MockCalled -Times 1 Get-Service
	}
}