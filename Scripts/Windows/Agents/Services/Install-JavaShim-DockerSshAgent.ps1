function Install-JavaShim-DockerSshAgent {

    Copy-Item ${PSScriptRoot}\Run-JavaShim-DockerSshAgent.bat C:\Windows\System32\java.bat -ErrorAction Stop

}