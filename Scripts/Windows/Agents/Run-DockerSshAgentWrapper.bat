@echo off

REM This is the entry point for Jenkins starting an agent via SSH on a Windows host
REM The batch file proxies the call including all arguments to the Powershell script,
REM  which does the heavy lifting

powershell -ExecutionPolicy Bypass "try { %~dp0Run-DockerSshAgentWrapper.ps1 %* } catch { Write-Host $_; exit 1 }"
if errorlevel 1 exit /b 1