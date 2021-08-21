. ${PSScriptRoot}\..\Helpers\Ensure-TestToolVersions.ps1

BeforeAll {

	. ${PSScriptRoot}\Deploy-PlasticClientConfig.ps1

}

Describe 'Deploy-PlasticClientConfig' {

    It "Reports error if Expand-Archive fails; removes temp file" {

        [byte[]] $ZipContent = 0x1, 0x2, 0x3
        $ConfigFolder = "C:\PlasticConfig"

		Mock Expand-Archive { throw "Expand-Archive failed" }

        Mock Remove-Item { $RemoveItemCmdlet = Get-Command Remove-Item -CommandType Cmdlet; return & $RemoveItemCmdlet -Path $Path }

		{ Deploy-PlasticClientConfig -ZipContent $ZipContent -ConfigFolder $ConfigFolder } |
			Should -Throw "Expand-Archive failed"

        Assert-MockCalled -Times 1 Expand-Archive
        Assert-MockCalled -Times 1 Remove-Item
    }

    It "Succeeds if Expand-Archive succeeds; removes temp file" {

        [byte[]] $ZipContent = 0x1, 0x2, 0x3
        $ConfigFolder = "C:\PlasticConfig"

		Mock Expand-Archive -ParameterFilter { $DestinationPath -eq $ConfigFolder } { }
		Mock Expand-Archive { throw "Invalid invocation of Expand-Archive" }

        Mock Remove-Item { $RemoveItemCmdlet = Get-Command Remove-Item -CommandType Cmdlet; return & $RemoveItemCmdlet -Path $Path }

		{ Deploy-PlasticClientConfig -ZipContent $ZipContent -ConfigFolder $ConfigFolder } |
			Should -Not -Throw

        Assert-MockCalled -Times 1 Expand-Archive
        Assert-MockCalled -Times 1 Remove-Item
    }
}