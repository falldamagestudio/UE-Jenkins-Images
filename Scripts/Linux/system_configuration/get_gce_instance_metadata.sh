#!/bin/bash

# Retrieve GCE instance metadata
get_gce_instance_metadata () {

    local KEY=$1

    local METADATA=http://metadata.google.internal/computeMetadata/v1
    local VALUE
    VALUE=$(curl --silent -H 'Metadata-Flavor: Google' "${METADATA}/instance/attributes/${KEY}") || return

    echo "${VALUE}"
}
