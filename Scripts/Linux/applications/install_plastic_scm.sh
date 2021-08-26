#!/bin/bash

function install_plastic_scm () {

    apt-get update
    apt-get install -y apt-transport-https wget gpg-agent --no-install-recommends
    echo "deb https://www.plasticscm.com/plasticrepo/stable/debian/ ./" | tee /etc/apt/sources.list.d/plasticscm-stable.list
    wget https://www.plasticscm.com/plasticrepo/stable/debian/Release.key --quiet -O - | apt-key add -
    apt-get update
    apt-get install -y plasticscm-client-core --no-install-recommends

    apt-get clean
    rm -rf /var/lib/apt/lists/*

}

