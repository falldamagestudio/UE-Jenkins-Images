# Log all output to file (in addition to console output, when run manually )
# This enables post-mortem inspection of the script's activities via log files
# It also allows GCE's logging agent to pick up the activity and forward it to Google's Cloud Logging
Start-Transcript -LiteralPath "C:\Logs\GCEService-SshAgent-Startup-$(Get-Date -Format "yyyyMMdd-HHmmss" -ErrorAction Stop).txt" -ErrorAction Stop

try {

    $VMSettings = Import-PowerShellDataFile -Path "${PSScriptRoot}\..\..\VMSettings.psd1" -ErrorAction Stop

    # Stop this service explicitly
    # It keeps Windows from automatically restarting the service
    # However, Windows will start it again at next boot

    Stop-Service $VMSettings.JenkinsAgentServiceName

    # After Stop-Service has run, The remainder of the script (including the 'finally' section) will not be run

} finally {

    Stop-Transcript

}