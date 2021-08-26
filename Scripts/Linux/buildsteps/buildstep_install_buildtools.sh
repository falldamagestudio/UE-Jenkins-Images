#!/bin/bash

SCRIPTS_DIR="${BASH_SOURCE%/*}"

. "${SCRIPTS_DIR}/../applications/install_buildtools.sh"

function buildstep_install_buildtools () {

    install_buildtools
}
