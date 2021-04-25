. ${PSScriptRoot}\Invoke-External.ps1

function Create-PlasticClientConfigLinks {

    <#
        Create symlinks for some of the Plastic client config files, to a nonexistent folder
        Those config files should be made present somehow (for example, via a volume mount) before using cm.exe
        This allows the volume mount to provide those files via a read-only file system, while
          still allowing cm.exe to write to other files within the config folder
    #>

    class CreateSymlinkException : Exception {
        $SourceLocation
        $TargetLocation

        CreateSymlinkException([string] $sourceLocation, [string] $targetLocation) : base("Unable to create symlink from ${sourceLocation} to ${targetLocation}") { $this.SourceLocation = $sourceLocation; $this.targetLocation = $targetLocation }
    }

    function CreateSymlink {
        param (
            [Parameter(Mandatory=$true)][string]$SourceLocation,
            [Parameter(Mandatory=$true)][string]$TargetLocation
        )

        $ExitCode = Invoke-External -LiteralPath "cmd" "/c" "mklink" $SourceLocation $TargetLocation
        if ($ExitCode -ne 0) {
            throw [CreateSymlinkException]::new($SourceLocation, $TargetLocation)
        }
    }

    $SourceFolder = "${env:LOCALAPPDATA}\plastic4"
    $TargetFolder = "C:\plastic-config"

    # Create folder for config files
    New-Item -ItemType Directory -Path $SourceFolder | Out-Null

    # Symlink critical files from config folder to nonexistent folder
    CreateSymlink -SourceLocation (Join-Path $SourceFolder "client.conf") -TargetLocation (Join-Path $TargetFolder "client.conf")
    CreateSymlink -SourceLocation (Join-Path $SourceFolder "cryptedservers.conf") -TargetLocation (Join-Path $TargetFolder "cryptedservers.conf")
    CreateSymlink -SourceLocation (Join-Path $SourceFolder "cryptedserver.key") -TargetLocation (Join-Path $TargetFolder "cryptedserver.key")
}
