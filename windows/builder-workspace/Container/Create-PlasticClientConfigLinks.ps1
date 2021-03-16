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

    $Process = Start-Process -FilePath "cmd" -ArgumentList "/c","mklink",$SourceLocation,$TargetLocation -NoNewWindow -Wait -PassThru
    if ($Process.ExitCode -ne 0) {
        throw [CreateSymlinkException]::new($SourceLocation, $TargetLocation)
    }
}

function Create-PlasticClientConfigLinks {

    <#
        Create symlinks for some of the Plastic client config files, to a nonexistent folder
        Those config files should be made present somehow (for example, via a volume mount) before using cm.exe
        This allows the volume mount to provide those files via a read-only file system, while
          still allowing cm.exe to write to other files within the config folder
    #>

    $SourceFolder = "C:\Users\Jenkins\AppData\Local\plastic4"
    $TargetFolder = "C:\plastic-config"

    CreateSymlink -SourceLocation (Join-Path $SourceFolder "client.conf") -TargetLocation (Join-Path $TargetFolder "client.conf")
    CreateSymlink -SourceLocation (Join-Path $SourceFolder "cryptedservers.conf") -TargetLocation (Join-Path $TargetFolder "cryptedservers.conf")
    CreateSymlink -SourceLocation (Join-Path $SourceFolder "cryptedserver.key") -TargetLocation (Join-Path $TargetFolder "cryptedserver.key")
}
