#!/bin/bash

# Get GCE project ID associated with current service account
# This will first attempt to fetch the project ID from ADC, and if ADC are not specified, from VM instance metadata
# Returns either a project ID, or "" if failed
get_gce_project_id () {

    if [ -z "${GOOGLE_APPLICATION_CREDENTIALS}" ]; then

        # No ADC have been specified; let's attempt to get project ID from VM metadata

        local METADATA
        METADATA=http://metadata.google.internal/computeMetadata/v1

        local PROJECT
        PROJECT=$(curl --silent -H 'Metadata-Flavor: Google' "${METADATA}/project/project-id") || return

        echo -n "${PROJECT}"
    else
        # Fetch project ID from ADC

        local PROJECT
        PROJECT=$(cat "${GOOGLE_APPLICATION_CREDENTIALS}" | jq -r ".project_id") || return

        echo -n "${PROJECT}"
    fi
}
