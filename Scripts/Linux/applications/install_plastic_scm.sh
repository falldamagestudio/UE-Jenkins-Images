#!/bin/bash

function install_plastic_scm () {

    sudo apt-get update || return
    sudo --preserve-env=DEBIAN_FRONTEND apt-get install -y apt-transport-https wget gpg-agent --no-install-recommends || return
    { echo "deb https://www.plasticscm.com/plasticrepo/stable/debian/ ./" || return ; } | { sudo tee /etc/apt/sources.list.d/plasticscm-stable.list || return ; }
    { wget https://www.plasticscm.com/plasticrepo/stable/debian/Release.key --quiet -O - || return ; } | { sudo apt-key add - || return ; }
    sudo apt-get update || return
    sudo --preserve-env=DEBIAN_FRONTEND apt-get install -y plasticscm-client-core --no-install-recommends || return

    sudo apt-get clean || return
    sudo rm -rf /var/lib/apt/lists/*

}

