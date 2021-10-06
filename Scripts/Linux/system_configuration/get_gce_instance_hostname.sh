#!/bin/bash

# Retrieve hostname from GCE instance metadata
get_gce_instance_hostname () {

    local METADATA=http://metadata.google.internal/computeMetadata/v1
    local HOSTNAME
    HOSTNAME=$(curl --silent -H 'Metadata-Flavor: Google' "${METADATA}/instance/hostname") || return

    echo "${HOSTNAME}" || return
}

