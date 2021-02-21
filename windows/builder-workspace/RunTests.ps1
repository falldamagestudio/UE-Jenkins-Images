class PesterException : Exception {
	$NumFailedTests

	PesterException([int] $numFailedTests) : base("${numFailedTests} tests failed") { $this.NumFailedTests = $numFailedTests }
}

# Run Pester tests, both for host OS scripts and container scripts
Invoke-Pester

# Pester will return number of failed tests as its exit code; convert nonzero exit codes into exceptions
if ($LASTEXITCODE -ne 0) {
	throw [PesterException]::new($LASTEXITCODE)
}
