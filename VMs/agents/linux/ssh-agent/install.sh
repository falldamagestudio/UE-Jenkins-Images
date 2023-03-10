#!/bin/bash

set -o nounset
set -o pipefail
shopt -s inherit_errexit

. "${BASH_SOURCE%/*}/../../../../Scripts/Linux/buildsteps/buildstep_create_agent_host_folders.sh"
. "${BASH_SOURCE%/*}/../../../../Scripts/Linux/buildsteps/buildstep_install_buildtools.sh"
. "${BASH_SOURCE%/*}/../../../../Scripts/Linux/buildsteps/buildstep_install_scm_tools.sh"
. "${BASH_SOURCE%/*}/../../../../Scripts/Linux/applications/install_adoptium_openjdk.sh"
. "${BASH_SOURCE%/*}/../../../../Scripts/Linux/buildsteps/buildstep_install_services.sh"

# Eliminate warnings such as this when running apt-get:
#   debconf: unable to initialize frontend: Dialog
export DEBIAN_FRONTEND=noninteractive

buildstep_create_agent_host_folders || exit
buildstep_install_buildtools || exit
buildstep_install_scm_tools || exit
install_adoptium_openjdk || exit
buildstep_install_services || exit
