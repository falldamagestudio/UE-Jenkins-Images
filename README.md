# UE-Jenkins-Images

This repository contains the logic necessary to build all Docker images used by UE-Jenkins-BuildSystem.

Repository secrets that need to be set for the GitHub Actions workflows to function:

* `ARTIFACT_REGISTRY_LOCATION`: The region in which the Google Artifact Registry is located. Example: `europe-west1`
* `GOOGLE_CLOUD_PROJECT_ID`: The GCP project that contains all cloud resources (build machinery, GAR). Example: `my-google-cloud-project`
* `GOOGLE_CLOUD_BUILD_ARTIFACT_UPLOADER_SERVICE_ACCOUNT_KEY`: JSON file for authenticating as `build-artifact-uploader@<projectid>.iam.gserviceaccount.com`
* `GOOGLE_CLOUD_IMAGE_BUILDER_INSTANCE_CONTROLLER_SERVICE_ACCOUNT_KEY`: JSON file for authenticating as `image-builder-instance-ctl@<projectid>.iam.gserviceaccount.com`
* `GOOGLE_CLOUD_REGION`: The region in which VMs will be run that creates Windows images. Example: `europe-west1`
* `GOOGLE_CLOUD_ZONE`: The region in which VMs will be run that creates Windows images. Example: `europe-west1-b`
