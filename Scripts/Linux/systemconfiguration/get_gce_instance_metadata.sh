#!/bin/bash

# Retrieve GCE instance metadata
get_gce_instance_metadata () {

    local KEY=$1

    local METADATA=http://metadata.google.internal/computeMetadata/v1
    local VALUE=$(curl -H 'Metadata-Flavor: Google' "${METADATA}/instance/attributes/${KEY}")

    echo "${VALUE}"
}
