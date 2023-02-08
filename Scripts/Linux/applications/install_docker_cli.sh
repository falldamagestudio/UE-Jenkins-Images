#!/bin/bash

function install_docker_cli () {
    apt-get update || return
    apt-get install -y apt-transport-https lsb-release curl ca-certificates gpg --no-install-recommends || return
    { curl -fsSL https://download.docker.com/linux/debian/gpg || return ; } | { gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg || return ; }
    { echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" || return ; } | { tee /etc/apt/sources.list.d/docker.list > /dev/null || return ; }
    apt-get update || return
    apt-get install -y docker-ce-cli --no-install-recommends || return

    apt-get clean || return
    rm -rf /var/lib/apt/lists/* || return
}
