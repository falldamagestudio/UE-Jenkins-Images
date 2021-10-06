#!/bin/bash

. "${BASH_SOURCE%/*}/../applications/install_docker_cli.sh"
. "${BASH_SOURCE%/*}/../applications/install_git.sh"
. "${BASH_SOURCE%/*}/../applications/install_plastic_scm.sh"

function buildstep_install_scm_tools () {

    install_docker_cli || return
    install_git || return
    install_plastic_scm || return
}
