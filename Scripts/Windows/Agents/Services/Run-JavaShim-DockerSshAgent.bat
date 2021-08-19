@echo off

REM This is the entry point for Jenkins starting an agent via SSH on a Windows host
REM The batch file proxies the call including all arguments to the Powershell script,
REM  which does the heavy lifting

REM This file should be copied to C:\Windows\System32\java.bat. it will act as a shim
REM  layer on a system that doesn't have Java installed. It is only capable of running
REM  the Dockerized SSH Agent. It will typically be launched like this:
REM
REM    java -jar <path to agent .jar>

powershell -ExecutionPolicy Bypass "try { & C:\Scripts\Windows\Agents\Services\Run-JavaShim-DockerSshAgent.ps1 %* } catch { Write-Host $_; exit 1 }"
if errorlevel 1 exit /b 1