# Containerized build tools for Unreal Engine

This repository contains build logic that create Docker images with the tools needed to build Unreal Engine source code and run Unreal Engine tools (such as `UE4Editor-Cmd`).

# Windows build tools container

## Status

This container is proven to work - building Unreal Engine plus example game code & cooking content works.

## Implementation

The build process creates a Windows Server VM in Google Cloud, runs the Docker image build process on that VM, and tears down the VM afterward. This is necessary since Windows containers are tightly coupled to the host OS version, and we want to build it specifically on Windows Server 2019.

The container will be based on Windows Server Core. Some installation steps cannot be run within Windows Server Core; these steps are run on the host VM, and the necessary files are injected from the host's file system into the image build process.

## Known gotchas

If you cancel the build job while the helper VM exists, the VM will not be deleted automatically -- you will need to clean it up yourself.

# Linux build tools container

## Status

This container has not been fully tested out. UE's setup script fails if UE is configured as a submodule in a Git repository. That blocker needs to be resolved within the UE build jobs themselves rather than within this container.

# License

Most of this is licensed according to [the main license](LICENSE.txt).

This repository includes parts of https://github.com/GoogleCloudPlatform/cloud-builders-community which is licensed according to [a separate license](windows/builder/LICENSE.txt).
