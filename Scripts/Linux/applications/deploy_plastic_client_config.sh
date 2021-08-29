#!/bin/bash

function deploy_plastic_client_config () {

    local PLASTIC_CONFIG_BASE64=$1

    local PLASTIC_CONFIG_FOLDER="${HOME}/.plastic4"

    mkdir "${PLASTIC_CONFIG_FOLDER}" || return

    { echo "${PLASTIC_CONFIG_BASE64}"  || return ; } | { base64 --decode || return ; } | { tar -zxv --directory="${PLASTIC_CONFIG_FOLDER}" || return ; }
}
