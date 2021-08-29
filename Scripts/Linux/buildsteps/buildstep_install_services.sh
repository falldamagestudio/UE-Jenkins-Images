#!/bin/bash

. "${BASH_SOURCE%/*}/../system_configuration/install_service.sh"

function buildstep_install_services () {

    JENKINS_AGENT_UNIT_FILE=$1

    install_service "${BASH_SOURCE%/*}/../agents/services/vm_startup.service" "vm_startup.service"

    if [ "${JENKINS_AGENT_UNIT_FILE}" != "" ]; then
        install_service "${JENKINS_AGENT_UNIT_FILE}" "jenkins_agent.service"
    fi
}