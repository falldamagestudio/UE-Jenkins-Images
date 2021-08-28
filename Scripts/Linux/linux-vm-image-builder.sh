#!/bin/bash

SCRIPTS_DIR="${BASH_SOURCE%/*}"

PACKER_SCRIPT="$1"
PROJECT_ID="$2"
ZONE="$3"
IMAGE_NAME="$4"

if [ $# -ne 4 ]; then
	1>&2 echo "Usage: linux-vm-image-builder.sh <packer script> <project ID> <zone> <image name>"
	exit 1
fi

SOURCE_IMAGE=$(jq -r ".linux.vm_image_builder_source_image" "${SCRIPTS_DIR}/tools-and-versions.json")

packer init "${PACKER_SCRIPT}"

packer build \
    -var "project_id=${PROJECT_ID}" \
    -var "zone=${ZONE}" \
    -var "network=image-builder-network" \
    -var "subnetwork=image-builder-subnetwork" \
    -var "machine_type=n1-standard-2" \
    -var "source_image=${SOURCE_IMAGE}" \
    -var "image_name=${IMAGE_NAME}" \
    "${PACKER_SCRIPT}"
