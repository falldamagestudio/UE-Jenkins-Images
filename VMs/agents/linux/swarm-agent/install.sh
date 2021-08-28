#!/bin/bash

set -o nounset
set -o pipefail
shopt -s inherit_errexit

. "${BASH_SOURCE%/*}/../../../../Scripts/Linux/buildsteps/buildstep_install_buildtools.sh"
. "${BASH_SOURCE%/*}/../../../../Scripts/Linux/buildsteps/buildstep_install_scm_tools.sh"
. "${BASH_SOURCE%/*}/../../../../Scripts/Linux/applications/install_adoptium_openjdk.sh"
. "${BASH_SOURCE%/*}/../../../../Scripts/Linux/applications/install_jenkins_swarm_agent.sh"

buildstep_install_buildtools || exit 1
buildstep_install_scm_tools || exit 1
install_adoptium_openjdk || exit 1
install_jenkins_swarm_agent || exit 1