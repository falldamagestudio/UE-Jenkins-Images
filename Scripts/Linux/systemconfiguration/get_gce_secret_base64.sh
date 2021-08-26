#!/bin/bash

# Retrieve a secret from GCP Secret Manager (base64-encoded)
# If the secret is not known, returns ""
get_gce_secret_base64 () {

    local SECRET_NAME=$1

    local METADATA=http://metadata.google.internal/computeMetadata/v1

    # Fetch access token for google APIs
    local ACCESS_TOKEN=$(curl -H 'Metadata-Flavor: Google' "${METADATA}/instance/service-accounts/default/token" | cut -d '"' -f 4)
    #Typical response format from curl call:
    #   {
    #     "name": "projects/<id>/secrets/<name>/versions/1",
    #     "payload": {
    #       "data": "<base64 encoded string>"
    #     }
    #   }

    local PROJECT=$(curl -H 'Metadata-Flavor: Google' ${METADATA}/project/project-id)

    local SECRET_RESPONSE=$(curl https://secretmanager.googleapis.com/v1/projects/${PROJECT}/secrets/${SECRET_NAME}/versions/latest:access -H "Authorization: Bearer ${ACCESS_TOKEN}")

    if [ "$(echo ${SECRET_RESPONSE} | awk -F "\"" '{print $2}')" != 'error' ]; then
        local SECRET=$(echo ${SECRET_RESPONSE} | awk -F "\"" '{print $10}')
        echo $SECRET
    fi
}
