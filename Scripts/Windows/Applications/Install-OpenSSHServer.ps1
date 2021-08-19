function Install-OpenSSHServer {

    # We install OpenSSH by manually installing OpenSSH
    # This requires Chocolatey to already be installed

    # There is an official method for installing OpenSSH on Windows 10 / Windows Server 2019,
    # short and to the point:
    #   Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    # Reference: https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse#install-openssh-using-powershell
    #
    # However, this method was only introduced in Windows 10.0.17763 and it
    #  does or does not work depending on which patches are installed. People
    #  are experiencing problems both on 10.0.17763 and newer versions:
    #  https://github.com/MicrosoftDocs/windowsserverdocs/issues/2074
    # It is unclear whether there's just a need to be on a "recent enough" patch
    #  level, or whether MS are occasionally breaking/repairing it.
    #
    # The default image for Windows Server 2019 Core on Google Cloud (windows-server-2019-dc-core-for-containers-v20210608)
    #  is version 10.0.17763.1999 (as reported by 'cmd /c ver'). Add-WindowsCapability errors
    #  out with "access denied" on such a machine. Installing all available Windows Updates
    #  results in a Windows installation where Add-WindowsCapability is successful.
    # Installing Windows updates when running Packer is straightforward
    #  - use the https://github.com/rgl/packer-plugin-windows-update package -
    #  but it's a lot more convoluted when you fire up a clean VM for local testing
    #  of the installation process; you need to use
    #  JEA (https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/jea/role-capabilities?view=powershell-7.1)
    #  to create a session configuration, then disconnect, start a new session using that
    #  configuration, install PSWindowsUpdate (https://www.powershellgallery.com/packages/PSWindowsUpdate/2.2.0.2)
    #  and then run windows update installation. Only then can you continue with
    #  invoking Add-WindowsCapability on your test machine.
    #
    # Given all the above, we choose to use an OpenSSH package distributed via Chocolatey instead.

    # Note that, at the time of writing, the latest non-beta package (8.0.0.1) does not work well with
    #  Jenkins & PowerShell:
    #
    #  1. The SSH server will determine that it's being used non-interactively, and will therefore
    #     not create a PTY.
    #  2. Jenkins logs in to the machine and runs 'java <options>'. This invokes the Java shim, which forwards to Run-JavaShim-DockerSshAgent.ps1.
    #  3. Run-JavaShim-DockerSshAgent.ps1 issues some commands that want to show progress (Copy-Item, Expand-Archive. ...)
    #  4. Powershell's progress display logic attempts to read from stdout.
    #  5. Since there is no PTY, reading from stdout results in a Win32-level access denied.
    #  6. The Powershell command in question fails. (Setting progress preference to "SilentlyContinue" makes
    #     no difference.)
    #
    #  Version 8.6.0-beta1 is new enough to allocate a PTY, and therefore avoid the above problem scenario.
    #  Reference: https://mangolassi.it/post/518620

    $OpenSSHVersion = "8.6.0-beta1"

    choco install -y openssh --version $OpenSSHVersion -params '"/SSHServerFeature /KeyBasedAuthenticationFeature"'
}
