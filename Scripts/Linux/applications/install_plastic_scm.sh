#!/bin/bash

function install_plastic_scm () {

    ${SUDO} apt-get update || return
    ${SUDO} apt-get install -y apt-transport-https ca-certificates wget gnupg --no-install-recommends || return
    { echo "deb https://www.plasticscm.com/plasticrepo/stable/debian/ ./" || return ; } | { ${SUDO} tee /etc/apt/sources.list.d/plasticscm-stable.list || return ; }
    { wget https://www.plasticscm.com/plasticrepo/stable/debian/Release.key --quiet -O - || return ; } | { ${SUDO} apt-key add - || return ; }
    ${SUDO} apt-get update || return
    ${SUDO} apt-get install -y plasticscm-client-core --no-install-recommends || return

    ${SUDO} apt-get clean || return
    ${SUDO} rm -rf /var/lib/apt/lists/* || return

}

