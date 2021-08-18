function Copy-SystemDLLs {

	param (
		[Parameter(Mandatory=$true)] [string] $SourceFolder,
		[Parameter(Mandatory=$true)] [string] $TargetFolder
	)

	$DLLNames = @(
		# This provides XINPUT1_3.DLL which is used when running the C++ apps (UE4Editor-Cmd.exe for example), even in headless mode
		# Normally, you would install the DirectX Redistributable to get this DLL onto the system. However, the DirectX redist cannot be installed
		#  within a Windows Server Core container (the installer will error out with exit code -9). Because of this, the surrounding VM
		#  will have to provide the DLL as-is and this is then copied to the appropriate location.
		"XINPUT1_3.DLL"

		# Similarly, this DLL is part of DirectX, and cannot be installed directly into a Windows Server Core container.
		# This is needed when loading UE4Editor-ShaderFormatD3D.dll.
		"D3DCOMPILER_43.DLL"

		# Similarly, this DLL is part of DirectX, and cannot be installed directly into a Windows Server Core container.
		# This is part of a dependency chain like so: UE4Editor-OnlineSubsystem*.dll => UE4Editor-OnlineSubsystemUtils.dll => UE4Editor-Voice.dll => DSOUND.dll
		"DSOUND.DLL"

		# Similarly, this DLL is part of DirectX, and cannot be installed directly into a Windows Server Core container.
		# This is part of a dependency chain like so: UE4Editor-XAudio2.dll => X3DAudio1_7.dll, XAPOFX1_5.dll
		"X3DAUDIO1_7.DLL"
		"XAPOFX1_5.DLL"

		# These DLLs are part of core OpenGL. They are present in a standard Windows Server
		#  installation but not a Windows Server Core container.
		# These are needed when loading UE4Editor-ShaderFormatOpenGL.dll.
		"OPENGL32.DLL"
		"GLU32.DLL"
	)

	foreach ($DLLName in $DLLNames) {

		$SourceLocation = (Join-Path $SourceFolder $DLLName -ErrorAction Stop)
		$TargetLocation = (Join-Path $TargetFolder $DLLName -ErrorAction Stop)

		Copy-Item -Path $SourceLocation -Destination $TargetLocation -ErrorAction Stop
	}
}
