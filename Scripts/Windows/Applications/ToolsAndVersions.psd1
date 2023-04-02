@{
    # Reference: https://adoptium.net/archive.html?variant=openjdk11&jvmVariant=hotspot
    AdoptiumOpenJDKInstallerUrl = "https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.12%2B7/OpenJDK11U-jdk_x64_windows_hotspot_11.0.12_7.msi"

    # This download link is for the Windows 10 SDK, version 2004 (10.0.19041.0)
    # We will only use it to install the Windows Debugging Tools (OptionId.WindowsDesktopDebuggers), not the SDK itself
    # As for the Windows 10 SDK itself, we will install that via the Visual Studio Build Tools installer
    # Reference: https://developer.microsoft.com/en-us/windows/downloads/sdk-archive/
    DebuggingToolsForWindowsInstallerUrl = "https://go.microsoft.com/fwlink/p/?linkid=2120843"

    # DirectX End-User Runtimes (June 2010)
    # Reference: https://www.microsoft.com/en-us/download/details.aspx?id=8109
    DirectXRedistributableInstallerUrl = "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe"

    # We are no longer using the web installer. It is too finicky to get working in different situations.
    # It won't install within a Windows Server Core container.
    # It will install within a Windows Server Desktop VM, if driven by the windows-docker-image-builder ... but not by packer (dxwebsetup exits with exit code -9).
    DirectXRedistributableWebInstallerUrl = "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe"

    # Reference: https://github.com/StefanScherer/docker-cli-builder/releases
    DockerCLIInstallerUrl = "https://github.com/StefanScherer/docker-cli-builder/releases/download/20.10.5/docker.exe"

    # Reference: https://cloud.google.com/logging/docs/agent/logging/installation#install-specific-version
    GCELoggingAgentInstallerUrl = "https://dl.google.com/cloudagents/windows/StackdriverLogging-v1-15.exe"

    # Reference: https://github.com/git-for-windows/git/releases
    GitInstallerUrl = "https://github.com/git-for-windows/git/releases/download/v2.33.0.windows.1/Git-2.33.0-64-bit.exe"

    # Reference: https://cloud.google.com/sdk/docs/downloads-versioned-archives
    # Reference: https://console.cloud.google.com/storage/browser/cloud-sdk-release
    GoogleCloudSDKInstallerUrl = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-336.0.0-windows-x86_64-bundled-python.zip"

    # Reference: https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent/installation#install-latest-version
    GoogleCloudOpsAgentInstallScriptUrl = "https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.ps1"

    # The official download URL is on the format,
    # https://repo.jenkins-ci.org/native/releases/org/jenkins-ci/plugins/swarm-client/<version>/swarm-client-<version>.jar
    # but when we hit that directly we get 404 back
    # Therefore we use an artifactory-related URL instead - it appears to work better
    JenkinsSwarmAgentDownloadUrl = "https://repo.jenkins-ci.org/artifactory/releases/org/jenkins-ci/plugins/swarm-client/3.28/swarm-client-3.28.jar"

    # Reference: https://community.chocolatey.org/packages/openssh/8.0.0.1#versionhistory
    OpenSSHVersion = "8.6.0-beta1"

    # Reference: https://www.plasticscm.com/download/
    PlasticInstallerUrl = "https://www.plasticscm.com/download/downloadinstaller/10.0.16.5882/plasticscm/windows/client"

    VC2010RedistributableX64InstallerUrl = "https://download.microsoft.com/download/3/2/2/3224B87F-CFA0-4E70-BDA3-3DE650EFEBA5/vcredist_x64.exe"

    VisualStudioBuildTools = @{
        # Reference: https://visualstudio.microsoft.com/downloads/?q=build+tools#build-tools-for-visual-studio-2019
        # Reference: https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2019#create-and-build-the-dockerfile
        InstallerUrl = "https://aka.ms/vs/16/release/vs_buildtools.exe"

        # Reference: https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2019
        WorkloadsAndComponents = @(

            # Required to build AutomationTool

            "Microsoft.Component.MSBuild"                                   # MSBuild
            "Microsoft.Net.Component.4.6.2.TargetingPack"                   # .NET Framework 4.6.2 targeting pack
            "Microsoft.VisualStudio.Component.Windows10SDK.18362"           # Windows 10 SDK (10.0.18362.0)

            # Required to build UnrealHeaderTool, as well as other C++ code

            # We lock the compiler version to a slightly older version of the VS 2019 C++ compiler
            # This ensures that the lib files produced when building the engine can be used by
            #  individual developers, as long as they have the same or a newer version of the
            #  toolchain installed on their machines
            "Microsoft.VisualStudio.Component.VC.14.28.16.9.x86.x64"        # MSVC v142 - VS 2019 C++ x64/x86 build tools (v14.28-16.9)
            # UnrealHeaderTool needs NetFxSdk.
            # This is included as part of any .NET SDK >= 4.6.0.
            # The easiest way to get hold of it is by installing the default .NET SDK for VS 2019.
            "Microsoft.Net.Component.4.8.SDK"                               # .NET Framework 4.8 SDK

            # Required to build SwarmCoordinator

            "Microsoft.Net.Component.4.5.TargetingPack"                     # .NET Framework 4.5 targeting pack
		)
    }

}