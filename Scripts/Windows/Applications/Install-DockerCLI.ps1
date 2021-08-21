class DockerCLIInstallerException : Exception {
	$ExitCode

	DockerCLIInstallerException([int] $exitCode) : base("Docker CLI installer exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Install-DockerCLI {

	$ToolsAndVersions = Import-PowerShellDataFile -Path "${PSScriptRoot}\ToolsAndVersions.psd1" -ErrorAction Stop

    $InstallLocation = "C:\Program Files\Docker"
    $DockerExeLocation = (Join-Path -Path $InstallLocation -ChildPath "Docker.exe")

    # Create installation folder
    New-Item $InstallLocation -ItemType Directory -Force -ErrorAction Stop | Out-Null

    # Download Docker CLI
    # It is a standalone executable, built by an independent party since Docker are not providing a suitable package (see https://github.com/docker/cli/issues/2281)
    Invoke-WebRequest -UseBasicParsing -Uri $ToolsAndVersions.DockerCLIInstallerUrl -OutFile $DockerExeLocation -ErrorAction Stop

    # Add Docker folder to all users' PATH
    $AllUsersEnvironmentPath = 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
    $CurrentPath = (Get-ItemProperty -Path $AllUsersEnvironmentPath).Path
    $NewPath = "${CurrentPath};${InstallLocation}"
    Set-ItemProperty -Path $AllUsersEnvironmentPath -Name "Path" -Value $NewPath
}
