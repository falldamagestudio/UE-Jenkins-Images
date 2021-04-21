function Enable-Win32LongPaths {

	Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name "LongPathsEnabled" -Value 1

}
