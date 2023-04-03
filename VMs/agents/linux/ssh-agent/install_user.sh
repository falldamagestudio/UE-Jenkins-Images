#!/bin/bash

set -o nounset
set -o pipefail
shopt -s inherit_errexit

. "${BASH_SOURCE%/*}/../../../../Scripts/Linux/buildsteps/buildstep_create_agent_host_folders.sh"

# Eliminate warnings such as this when running apt-get:
#   debconf: unable to initialize frontend: Dialog
export DEBIAN_FRONTEND=noninteractive

buildstep_create_agent_host_folders || exit
