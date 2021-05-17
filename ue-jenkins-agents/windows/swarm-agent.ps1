if($args.Length -eq 1) {
	# if `docker run` only has one argument, we assume user is running alternate command like `powershell` or `pwsh` to inspect the image
	Invoke-Expression $args
} else {
    $AgentArguments = @('-jar', 'C:\ProgramData\Jenkins\swarm-client.jar')

    $AgentArguments += $args

    $JAVA_BIN = "java.exe"

    Start-Process -FilePath $JAVA_BIN -Wait -NoNewWindow -ArgumentList $AgentArguments
}