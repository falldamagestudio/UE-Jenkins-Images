. ${PSScriptRoot}\..\Helpers\Invoke-External-PrintStdout.ps1

function Create-PlasticClientConfigLinks {

    <#
        Create symlinks for some of the Plastic client config files, to a nonexistent folder
        Those config files should be made present somehow (for example, via a volume mount) before using cm.exe
        This allows the volume mount to provide those files via a read-only file system, while
          still allowing cm.exe to write to other files within the config folder
    #>

    param (
        [Parameter(Mandatory=$true)][string]$Path
    )

    class CreateSymlinkException : Exception {
        $SourceLocation
        $TargetLocation
        $ExitCode

        CreateSymlinkException([string] $sourceLocation, [string] $targetLocation, [int] $exitCode) : base("Unable to create symlink from ${sourceLocation} to ${targetLocation}, command terminated with exit code ${ExitCode}") { $this.SourceLocation = $sourceLocation; $this.targetLocation = $targetLocation; $this.ExitCode = $exitCode }
    }

    function CreateSymlink {
        param (
            [Parameter(Mandatory=$true)][string]$SourceLocation,
            [Parameter(Mandatory=$true)][string]$TargetLocation
        )

        $ExitCode = Invoke-External-PrintStdout -LiteralPath "cmd" -ArgumentList @("/c", "mklink", $SourceLocation, $TargetLocation)
        if ($ExitCode -ne 0) {
            throw [CreateSymlinkException]::new($SourceLocation, $TargetLocation, $ExitCode)
        }
    }

    $SourceFolder = "${env:LOCALAPPDATA}\plastic4"
    $TargetFolder = $Path

    # Create folder for config files
    New-Item -ItemType Directory -Path $SourceFolder | Out-Null

    # Symlink critical files from config folder to nonexistent folder
    CreateSymlink -SourceLocation (Join-Path $SourceFolder "client.conf") -TargetLocation (Join-Path $TargetFolder "client.conf")
    CreateSymlink -SourceLocation (Join-Path $SourceFolder "cryptedservers.conf") -TargetLocation (Join-Path $TargetFolder "cryptedservers.conf")
    CreateSymlink -SourceLocation (Join-Path $SourceFolder "cryptedserver.key") -TargetLocation (Join-Path $TargetFolder "cryptedserver.key")
}
