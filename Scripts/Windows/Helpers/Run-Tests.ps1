class PesterException : Exception {
	$NumFailedTests

	PesterException([int] $numFailedTests) : base("${numFailedTests} tests failed") { $this.NumFailedTests = $numFailedTests }
}

function Run-Tests
{
	param (
		[Parameter(Mandatory)] [string] $Path
	)

	# Run Pester tests, both for host OS scripts and container scripts
	Invoke-Pester -Path $Path

	# Pester will return number of failed tests as its exit code; convert nonzero exit codes into exceptions
	$NumFailedTests = $LASTEXITCODE

	if ($NumFailedTests -ne 0) {
		throw [PesterException]::new($NumFailedTests)
	}
}