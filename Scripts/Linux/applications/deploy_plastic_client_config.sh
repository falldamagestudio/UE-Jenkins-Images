#!/bin/bash

function deploy_plastic_client_config () {

    local PLASTIC_CONFIG_BASE64=$1

    echo "${PLASTIC_CONFIG_BASE64}" | base64 --decode | tar -zxv --directory=/mnt/disks/persistent-disk/.plastic4
}
