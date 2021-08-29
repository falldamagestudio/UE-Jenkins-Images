#!/bin/bash

. "${BASH_SOURCE%/*}/../system_configuration/install_service.sh"

function buildstep_install_services () {

    install_service "${BASH_SOURCE%/*}/../agents/services/vm_startup.service"
}