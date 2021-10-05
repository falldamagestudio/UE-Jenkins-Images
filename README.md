# UE-Jenkins-Images

This repository contains the logic necessary to build all Docker images and GCE machine images used by UE-Jenkins-BuildSystem.

## Docker images

| name                                 | Purpose                                             |
|--------------------------------------|-----------------------------------------------------|
| controller-\<sha1>                   | Allows running the Jenkins controller on Kubernetes |
| inbound-agent-\<sha1>-\<platform>    | Allows running Jenkins jobs on Kubernetes           |
| buildtools-\<sha1>-\<platform>       | Allows building UE applications on Kubernetes       |

NOTE: There used to be Docker images with ssh & swarm agents. These were removed because they
weren't useful in practice. See dda5d73 for the latest version before they were deleted.

## VM images

| name                                 | Purpose                                             |
|--------------------------------------|-----------------------------------------------------|
| ssh-agent-\<sha1>-\<platform>        | Allows running Jenkins jobs & building UE applications on dynamically-provisioned VMs |
| swarm-agent-\<sha1>-\<platform>      | Allows running Jenkins jobs & building UE applications on statically-provisioned VMs |

# Folder structure

[Docker](Docker) contains Dockerfiles + top-level build scripts for all Docker images + additional files necessary for creating specific Docker images. These files will not remain within the final Docker images.

[Scripts](Scripts) contains many reusable scripts. These files will remain within the final Docker / VM images.

[VMs](VMs) contains Packer build scripts + top-level build scripts for all VM images + additional files necessary when creating specific VM images. These files will not remain within the final VM images.

[windows-docker-image-builder](windows-docker-image-builder) is a helper tool for launching a Windows VM in GCE, and building a Docker image via that VM.

# Important configuration files

## Controller

The core Jenkins version is specified via [the controller's Dockerfile](Docker/controller/Dockerfile).

The Jenkins controller has its plugin list in [plugins.txt](Docker/controller/plugins.txt). After changing that file, run [update-plugins-with-dependencies.sh](Docker/controller/update-plugins-with-dependencies.sh). That will freeze all dependency versions into [plugins-with-dependencies.txt](Docker/controller/plugins-with-dependencies.txt) and makes rebuilding of the Jenkins image at a later time possible.

## Agents

The Windows images have tools & versions for all applications in [ToolsAndVersions.psd1](Scripts/Windows/Applications/ToolsAndVersions.psd1), and overall VM settings (paths and such) in [VMSettings.psd1](Scripts/Windows/VMSettings.psd1).

Source VM images for Linux/Windows agent building are specified in [tools-and-versions.json](Scripts/Linux/tools-and-versions.json).

Source Docker image versions are embedded within configuration files.

Linux applications are not version locked; most will just install the latest version from APT.

# Configuring GitHub Actions

Repository secrets that need to be set for the GitHub Actions workflows to function:

* `ARTIFACT_REGISTRY_LOCATION`: The region in which the Google Artifact Registry is located. Example: `europe-west1`
* `GOOGLE_CLOUD_PROJECT_ID`: The GCP project that contains all cloud resources (build machinery, GAR). Example: `my-google-cloud-project`
* `GOOGLE_CLOUD_BUILD_ARTIFACT_UPLOADER_SERVICE_ACCOUNT_KEY`: JSON file for authenticating as `build-artifact-uploader@<projectid>.iam.gserviceaccount.com`
* `GOOGLE_CLOUD_IMAGE_BUILDER_INSTANCE_CONTROLLER_SERVICE_ACCOUNT_KEY`: JSON file for authenticating as `image-builder-instance-ctl@<projectid>.iam.gserviceaccount.com`
* `GOOGLE_CLOUD_REGION`: The region in which VMs will be run that creates Windows images. Example: `europe-west1`
* `GOOGLE_CLOUD_ZONE`: The region in which VMs will be run that creates Windows images. Example: `europe-west1-b`
* `GOOGLE_CLOUD_CONFIG_STORAGE_BUCKET`: The bucket in which cloud config files will be stored. Example: `my-google-cloud-storage-bucket`
