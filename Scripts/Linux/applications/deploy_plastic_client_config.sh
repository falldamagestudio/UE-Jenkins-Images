#!/bin/bash

# This function is intended to be run as the user that will use the Plastic SCM tools

function deploy_plastic_client_config () {

    local PLASTIC_CONFIG_BASE64=$1

    local PLASTIC_CONFIG_FOLDER="${HOME}/.plastic4"

    mkdir -p "${PLASTIC_CONFIG_FOLDER}" || return

    { echo "${PLASTIC_CONFIG_BASE64}"  || return ; } | { base64 --decode || return ; } | { tar -zxv --directory="${PLASTIC_CONFIG_FOLDER}" || return ; }
}
