. ${PSScriptRoot}\..\Helpers\Invoke-External-PrintStdout.ps1

function Create-PlasticClientConfigLinks {

    <#
        Create a config folder for the current user + symlinks for some of the Plastic client config files, from the current user's config folder
        to a folder in a fixed location that is not user-specific
        Those config files should be made present somehow (for example, via a volume mount) before using cm.exe
        
        This solves several problems:
        - The host side can easily make the config files available within the container, without knowing
            the username (and home folder location) of the container user
        - The container side can read the config files from the user-specific config directory
        - The container side can write other files to the user-specific config directory (cm.exe wants to do this) side-by-side
            with the symlinks, even though the symlink target folder may be read-only (the volume mounted folder will be read-only)
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
