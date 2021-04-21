class AuthenticateDockerForGoogleArtifactRegistryException : Exception {
	$ExitCode

	AuthenticateDockerForGoogleArtifactRegistryException([int] $exitCode) : base("docker login -u _json_key <...> exited with code ${exitCode}") { $this.ExitCode = $exitCode }
}

function Authenticate-DockerForGoogleArtifactRegistry {

	<#
		.SYNOPSIS
		Configures Docker to use JSON key file authentication when accessing a particular Google Artifact Registry region
	#>

	param (
		[Parameter(Mandatory)] [string] $AgentKey,
		[Parameter(Mandatory)] [string] $Region
	)

	function fStartProcess([string]$sProcess,[string]$sArgs,[string]$sSTDIN)
	{
		$oProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
		$oProcessInfo.FileName = $sProcess
		$oProcessInfo.RedirectStandardInput = $true
		$oProcessInfo.UseShellExecute = $false
		$oProcessInfo.Arguments = $sArgs
		$oProcess = New-Object System.Diagnostics.Process
		$oProcess.StartInfo = $oProcessInfo
		$oProcess.Start() | Out-Null
		$oProcess.StandardInput.Write($sSTDIN)
		$oProcess.StandardInput.Close()
		$oProcess.WaitForExit() | Out-Null
		return $oProcess.ExitCode
	}

	function ToArray
	{
		begin
		{
			$output = @();
		}
		process
		{
			$output += $_;
		}
		end
		{
			return ,$output;
		}
	}

	$Application = "powershell"

	$ArgumentList = @(
		"docker"
		"login"
		"-u","_json_key"
		"--password-stdin"
		"${Region}-docker.pkg.dev"
	)

	$Arguments = $ArgumentList | ForEach-Object { "`"$PSItem`"" } | ToArray -Join " "

	$ExitCode = fStartProcess -sProcess $Application -sArgs $Arguments -sSTDIN $AgentKey

    if ($ExitCode -ne 0) {
		throw [AuthenticateDockerForGoogleArtifactRegistryException]::new($ExitCode)
    }

#    $Process = Start-Process -FilePath "docker" -ArgumentList "login","-u","_json_key","-p",$AgentKey,"https://${Region}-docker.pkg.dev" -NoNewWindow -Wait -PassThru

#    if ($Process.ExitCode -ne 0) {
#		throw [AuthenticateDockerForGoogleArtifactRegistryException]::new($Process.ExitCode)
#    }
}
