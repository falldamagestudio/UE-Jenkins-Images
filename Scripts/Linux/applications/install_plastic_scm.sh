#!/bin/bash

# In order to install Plastic SCM client on debian 11 we need to add debian 10 repositories using workaround
# Call add_debian_10_repos beforehand on that OS

function install_plastic_scm () {

    apt-get update || return
    apt-get install -y apt-transport-https ca-certificates wget gnupg --no-install-recommends || return
    { echo "deb https://www.plasticscm.com/plasticrepo/stable/debian/ ./" || return ; } | { tee /etc/apt/sources.list.d/plasticscm-stable.list || return ; }
    { wget https://www.plasticscm.com/plasticrepo/stable/debian/Release.key --quiet -O - || return ; } | { apt-key add - || return ; }
    apt-get update || return
    apt-get install -y plasticscm-client-core --no-install-recommends || return

    apt-get clean || return
    rm -rf /var/lib/apt/lists/* || return

}

