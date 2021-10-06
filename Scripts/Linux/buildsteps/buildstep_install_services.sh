#!/bin/bash

. "${BASH_SOURCE%/*}/../system_configuration/install_service.sh"

function buildstep_install_services () {

    install_service "${BASH_SOURCE%/*}/../agents/services/gce_service_vm_startup.service" "vm_startup.service" || return

    if [ $# = 1 ]; then
        JENKINS_AGENT_UNIT_FILE=$1
        install_service "${JENKINS_AGENT_UNIT_FILE}" "jenkins_agent.service" || return
    fi
}