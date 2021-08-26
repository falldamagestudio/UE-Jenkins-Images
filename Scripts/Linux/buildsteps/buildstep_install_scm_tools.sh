#!/bin/bash

SCRIPTS_DIR="${BASH_SOURCE%/*}"

. "${SCRIPTS_DIR}/../applications/install_docker_cli.sh"
. "${SCRIPTS_DIR}/../applications/install_plastic_scm.sh"

function buildstep_install_scm_tools () {

    install_docker_cli
    install_plastic_scm
}

