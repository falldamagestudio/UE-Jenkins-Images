#!/bin/bash

SCRIPTS_DIR="${BASH_SOURCE%/*}"
ROOT_DIR="${SCRIPTS_DIR}/../.."

BUILD_SCRIPT="$1"
DOCKERFILE="$2"
PROJECT_ID="$3"
REGION="$4"
ZONE="$5"
ARTIFACT_REGISTRY_LOCATION="$6"
IMAGE_NAME="$7"
IMAGE_TAG="$8"

if [ $# -ne 8 ]; then
	1>&2 echo "Usage: windows-docker-image-builder.sh <build Powershell script> <dockerfile> <project ID> <region> <zone> <artifact registry location> <image name> <image tag>"
	exit 1
fi

HOST_IMAGE="windows-cloud/global/images/windows-server-2019-dc-for-containers-v20210212"

SERVICE_ACCOUNT="build-artifact-uploader@${PROJECT_ID}.iam.gserviceaccount.com"

# This command is executed on the builder VM like this:
#
# Shell: cmd
# Current working directory: c:\workspace  (containing just one file, ${ROOT_DIR}/builder-files/builder-files.zip )
# Writing an error will signal an error to windows-docker-image-builder, which results in a nonzero exit code
#
# The current implementation extracts builder-files.zip to the root folder,
#  which makes the Docker and Scripts folders available as C:\Docker and C:\Scripts respectively
#  and then the build script is executed

COMMAND="powershell \
	try { \
		Expand-Archive -Path .\\builder-files.zip -DestinationPath C:\\; \
		\"C:\\${BUILD_SCRIPT}\" \
			-GceRegion \"${ARTIFACT_REGISTRY_LOCATION}\" \
			-Dockerfile \"C:\\${DOCKERFILE}\" \
			-ImageName \"${IMAGE_NAME}\" \
			-ImageTag \"${IMAGE_TAG}\"; \
		} catch { \
			Write-Error \$_ \
		} \
	"

(mkdir "${ROOT_DIR}/builder-files" && cd "${ROOT_DIR}" && zip -r builder-files/builder-files.zip . -i "Scripts/*" -i "Docker/*")

"${ROOT_DIR}/windows-docker-image-builder/main" \
   -labels type=windows-image-builder \
   -region "${REGION}" \
   -zone "${ZONE}" \
   -network image-builder-network \
   -subnetwork image-builder-subnetwork \
   -machineType n1-standard-4 \
   -diskType pd-ssd \
   -diskSizeGb 100 \
   -image "${HOST_IMAGE}" \
   -workspace-path "${ROOT_DIR}/builder-files" \
   -serviceAccount "${SERVICE_ACCOUNT}" \
   -command "${COMMAND}"

rm -r "${ROOT_DIR}/builder-files"
