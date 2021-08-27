#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
shopt -s inherit_errexit

SCRIPTS_DIR="${BASH_SOURCE%/*}"

. "${SCRIPTS_DIR}/../../../../Scripts/Linux/buildsteps/buildstep_install_buildtools.sh"
. "${SCRIPTS_DIR}/../../../../Scripts/Linux/buildsteps/buildstep_install_scm_tools.sh"

buildstep_install_buildtools
buildstep_install_scm_tools
