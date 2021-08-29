#!/bin/bash

. "${BASH_SOURCE%/*}/get_gce_instance_metadata.sh"
. "${BASH_SOURCE%/*}/get_gce_secret_base64.sh"

# Fetch settings from GCP Secrets Manager / GCE Instance Metadata
#
# Input should come as three arrays:
# SETTINGS_KEYS=("secret-name-1" "secret-name-2" "metadata-name-1")
# SETTINGS_SOURCES=("secret" "secret" "instance-metadata")
# SETTINGS_BINARY=("false" "true" "false")          <==== binary settings will be returned as base64 srings
# SETTINGS_RESULT=()   <=== this will receive the result afterward
#
# If WAIT is set to "true", this will sleep and retry until all results are available.
# Otherwise, this will return with empty strings for values that are not found.
#
# If PRINT_PROGRESS is set to "true", this will print status reports to stdout.

function get_gce_settings () {

    local -n SETTINGS_KEYS=$1
    local -n SETTINGS_SOURCES=$2
    local -n SETTINGS_BINARY=$3
    local -n SETTINGS_RESULT=$4
    local WAIT=$5
    local PRINT_PROGRESS=$6

    local DELAY=10

    while :
    do

        # Fetch each of the settings from Secrets Manager / Instance Metadata and populate result array

        local ALL_SETTINGS_FOUND=1
        SETTINGS_RESULT=()
        for ((INDEX = 0; INDEX < ${#SETTINGS_KEYS[@]}; INDEX++)); do
            local KEY=${SETTINGS_KEYS[INDEX]}
            local SOURCE=${SETTINGS_SOURCES[INDEX]}
            local BINARY=${SETTINGS_BINARY[INDEX]}

            local VALUE
            if [ "${SOURCE}" = "secret" ]; then
                VALUE=$(get_gce_secret_base64 "${KEY}")
                if [ "${BINARY}" != "true" ]; then
                    VALUE=$(echo "${VALUE}" | base64 --decode)
                fi
            elif [ "${SOURCE}" = "instance-metadata" ]; then
                VALUE=$(get_gce_instance_metadata "${KEY}") || return
            else
                return 1
            fi

            SETTINGS_RESULT+=("${VALUE}")
            if [ "${VALUE}" = "" ]; then
                ALL_SETTINGS_FOUND=0
            fi
        done

        # Print results, if requested

        if [ "${PRINT_PROGRESS}" != "false" ]; then
            for ((INDEX = 0; INDEX < ${#SETTINGS_KEYS[@]}; INDEX++)); do
                local KEY=${SETTINGS_KEYS[INDEX]}
                local SOURCE=${SETTINGS_SOURCES[INDEX]}
                local FOUND
                FOUND=$([ "${SETTINGS_RESULT[INDEX]}" != "" ] && echo "found" || echo "not found") || return
                echo "Setting type ${SOURCE}, key ${KEY}: ${FOUND}"
            done

            if ((ALL_SETTINGS_FOUND)); then
                echo "All settings found"
            fi
        fi

        # Are we done yet?
        if ((ALL_SETTINGS_FOUND)) || [ "${WAIT}" = "false" ]; then
            return 0
        else

           # Not done, sleep and try again

            if [ "${PRINT_PROGRESS}" != "false" ]; then
                echo "Some required settings are missing. Sleeping for ${DELAY} seconds, then retrying..."
            fi

            sleep "${DELAY}"
        fi
    done
}