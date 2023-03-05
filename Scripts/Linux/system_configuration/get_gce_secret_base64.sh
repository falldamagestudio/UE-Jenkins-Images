#!/bin/bash

. "${BASH_SOURCE%/*}/get_gce_access_token.sh"
. "${BASH_SOURCE%/*}/get_gce_project_id.sh"


# Retrieve a secret from GCP Secret Manager (base64-encoded)
# If the secret is not known, returns ""
get_gce_secret_base64 () {

    local SECRET_NAME=$1

    local ACCESS_TOKEN
    ACCESS_TOKEN=$(get_gce_access_token) || return
    local PROJECT
    PROJECT=$(get_gce_project_id) || return

    # Using access token, look up secret in GCP Secret Manager

    local SECRET_RESPONSE
    SECRET_RESPONSE=$(curl --silent -H "Authorization: Bearer ${ACCESS_TOKEN}" "https://secretmanager.googleapis.com/v1/projects/${PROJECT}/secrets/${SECRET_NAME}/versions/latest:access") || return

    if ! echo "${SECRET_RESPONSE}" | jq -e 'has("error")' > /dev/null; then
        # Secret lookup succeeded

        local SECRET
        SECRET=$(echo "${SECRET_RESPONSE}" | jq -r ".payload.data") || return
        echo "${SECRET}" || return
    fi

    # Secret lookup failed

    return
}
