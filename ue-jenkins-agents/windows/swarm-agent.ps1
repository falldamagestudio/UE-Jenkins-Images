if($args.Length -eq 1) {
    # if `docker run` only has one argument, we assume user is running alternate command like `powershell` or `pwsh` to inspect the image
    Invoke-Expression $args
} else {
    $AgentArguments = @('-jar', 'C:\ProgramData\Jenkins\swarm-client.jar')

    # Surround each argument with double quotes
    #
    # Start-Process requires that any arguments that include spaces be surrounded with double quotes. If this is not the case,
    #  then the new process will interpret each space as an argument separator.
    #
    # More detail:
    # Performing `Start-Process -FilePath hello.exe -ArgumentList @("a", "b c", "d")` will result in
    #  hello.exe being invoked with a singular argument string like `a b c d`,
    #  and hello.exe will subsequently parse the argument string as four separate arguments, namely "a", "b", "c", and "d".
    # This 'decay' happens because Start-Process uses Win32's CreateProcess API under the hood, and that API
    #  is literally "launch process <string X> with command line <string Y>".
    # Start-Process is documented to need manual quoting of its arguments to work around this,
    #  see [the -ArgumentList section of Start-Process)[https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-process?view=powershell-7.1#parameters]
    # 
    # This is usually not a problem when launching Jenkins agents ... except when passing multiple labels to the Swarm agent.
    # Multiple labels need to be passed as a single string, containing all the labels, separated by spaces. Example:
    #  -labels "label1 label2 label3"
    # If not quoted correctly, this results in misleading error messages from the argument parsing in Jenkins/Swarm's Java code.
    #
    # The appropriate place to handle the quoting is right here, just before calling Start-Process.
    #
    # (It might seem as though it should work fine to quote the original label-string in Powershell outside of Docker. Well, no,
    #  because Docker's commandline parsing will forcibly remove surrounding quotes from strings. Double/triple-quoting does not help...
    #  so extra quoting that is done on the host side, before calling Docker, will not survive all the way to this script.)

    $QuotedArgs = $args | ForEach-Object { """$_""" }

    $AgentArguments += $QuotedArgs

    $JAVA_BIN = "java.exe"

    Start-Process -FilePath $JAVA_BIN -Wait -NoNewWindow -ArgumentList $AgentArguments
}