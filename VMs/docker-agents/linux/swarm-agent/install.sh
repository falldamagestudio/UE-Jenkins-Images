#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
shopt -s inherit_errexit

. "${BASH_SOURCE%/*}/../../../../Scripts/Linux/buildsteps/buildstep_install_scm_tools.sh"

buildstep_install_scm_tools
