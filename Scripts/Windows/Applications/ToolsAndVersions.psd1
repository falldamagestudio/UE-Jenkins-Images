@{
    AdoptiumOpenJDKInstallerUrl = "https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.12%2B7/OpenJDK11U-jdk_x64_windows_hotspot_11.0.12_7.msi"

    DebuggingToolsForWindowsInstallerUrl = "https://go.microsoft.com/fwlink/p/?linkid=2120843"

    DirectXRedistributableInstallerUrl = "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe"

    # We are no longer using the web installer. It is too finicky to get working in different situations.
    # It won't install within a Windows Server Core container.
    # It will install within a Windows Server Desktop VM, if driven by the windows-docker-image-builder ... but not by packer (dxwebsetup exits with exit code -9).
    # DirectXRedistributableInstallerWebUrl = "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe"

    DockerCLIInstallerUrl = "https://github.com/StefanScherer/docker-cli-builder/releases/download/20.10.5/docker.exe"

    GCELoggingAgentInstallerUrl = "https://dl.google.com/cloudagents/windows/StackdriverLogging-v1-15.exe"

    GitInstallerUrl = "https://github.com/git-for-windows/git/releases/download/v2.33.0.windows.1/Git-2.33.0-64-bit.exe"

    GoogleCloudSDKInstallerUrl = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-336.0.0-windows-x86_64-bundled-python.zip"

    JenkinsRemotingAgentDownloadUrl = "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/4.7/remoting-4.7.jar"
    
    # The official download URL is on the format,
    # https://repo.jenkins-ci.org/native/releases/org/jenkins-ci/plugins/swarm-client/<version>/swarm-client-<version>.jar
    # but when we hit that directly we get 404 back
    # Therefore we use an artifactory-related URL instead - it appears to work better
    JenkinsSwarmAgentDownloadUrl = "https://repo.jenkins-ci.org/artifactory/releases/org/jenkins-ci/plugins/swarm-client/3.25/swarm-client-3.25.jar"

    OpenSSHVersion = "8.6.0-beta1"

    PlasticInstallerUrl = "https://www.plasticscm.com/download/downloadinstaller/10.0.16.5882/plasticscm/windows/client"

    VC2010RedistributableX64InstallerUrl = "https://download.microsoft.com/download/3/2/2/3224B87F-CFA0-4E70-BDA3-3DE650EFEBA5/vcredist_x64.exe"

    VisualStudioBuildTools = @{
        InstallerUrl = "https://aka.ms/vs/16/release/vs_buildtools.exe"

        WorkloadsAndComponents = @(
			"Microsoft.VisualStudio.Workload.VCTools"
			"Microsoft.VisualStudio.Component.VC.Tools.x86.x64"
			"Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools"	# Required to get PDBCOPY.EXE, which in turn is applied to all PDB files
			"Microsoft.VisualStudio.Component.Windows10SDK.18362"
			"Microsoft.Net.Component.4.6.2.TargetingPack"	# Required when building AutomationTool
			"Microsoft.Net.Component.4.5.TargetingPack"	# Required when building SwarmCoordinator
		)
    }

}