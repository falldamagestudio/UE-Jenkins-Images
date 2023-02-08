#!/bin/bash

set -o nounset
set -o pipefail
shopt -s inherit_errexit

#. "${BASH_SOURCE%/*}/../../../../Scripts/Linux/system_configuration/add_debian_10_repos.sh"
. "${BASH_SOURCE%/*}/../../../../Scripts/Linux/buildsteps/buildstep_create_agent_host_folders.sh"

# Eliminate warnings such as this when running apt-get:
#   debconf: unable to initialize frontend: Dialog
export DEBIAN_FRONTEND=noninteractive

#add_debian_10_repos || exit
buildstep_create_agent_host_folders || exit
