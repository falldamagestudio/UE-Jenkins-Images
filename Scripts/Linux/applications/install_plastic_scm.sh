#!/bin/bash

function install_plastic_scm () {

    apt-get update || return
    apt-get install -y apt-transport-https ca-certificates wget gnupg --no-install-recommends || return
    { curl -fsSL https://www.plasticscm.com/plasticrepo/stable/debian/Release.key || return ; } | { gpg --dearmor --yes -o /usr/share/keyrings/plasticscm.gpg || return ; }
    { echo "deb [arch=amd64 signed-by=/usr/share/keyrings/plasticscm.gpg] https://www.plasticscm.com/plasticrepo/stable/debian/ ./" || return ; } | { tee /etc/apt/sources.list.d/plasticscm-stable.list || return ; }
    apt-get update || return
    apt-get install -y plasticscm-client-core --no-install-recommends || return

    apt-get clean || return
    rm -rf /var/lib/apt/lists/* || return

}

