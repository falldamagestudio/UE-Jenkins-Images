#!/bin/bash

# Retrieve a secret from GCP Secret Manager (base64-encoded)
# If the secret is not known, returns ""
get_gce_secret_base64 () {

    local SECRET_NAME=$1

    local METADATA=http://metadata.google.internal/computeMetadata/v1

    # Fetch access token for google APIs
    local ACCESS_TOKEN
    ACCESS_TOKEN=$({ curl --silent -H 'Metadata-Flavor: Google' "${METADATA}/instance/service-accounts/default/token" || return ; } | { cut -d '"' -f 4 || return ; }) || return
    #Typical response format from curl call:
    #   {
    #     "name": "projects/<id>/secrets/<name>/versions/1",
    #     "payload": {
    #       "data": "<base64 encoded string>"
    #     }
    #   }

    local PROJECT
    PROJECT=$(curl --silent -H 'Metadata-Flavor: Google' "${METADATA}/project/project-id") || return

    local SECRET_RESPONSE
    SECRET_RESPONSE=$(curl --silent -H "Authorization: Bearer ${ACCESS_TOKEN}" "https://secretmanager.googleapis.com/v1/projects/${PROJECT}/secrets/${SECRET_NAME}/versions/latest:access") || return

    if ! echo "${SECRET_RESPONSE}" | jq -e 'has("error")' > /dev/null; then
        local SECRET
        SECRET=$(echo "${SECRET_RESPONSE}" | jq -r ".payload.data") || return
        echo "${SECRET}" || return
    fi
}
