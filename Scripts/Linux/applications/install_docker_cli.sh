#!/bin/bash

function install_docker_cli () {
    sudo apt-get update || return
    sudo --preserve-env=DEBIAN_FRONTEND apt-get install -y apt-transport-https lsb-release curl ca-certificates gpg --no-install-recommends || return
    { curl -fsSL https://download.docker.com/linux/debian/gpg || return ; } | { sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg || return ; }
    { echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" || return ; } | { sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || return ; }
    sudo apt-get update || return
    sudo --preserve-env=DEBIAN_FRONTEND apt-get install -y docker-ce-cli --no-install-recommends || return

    sudo apt-get clean || return
    sudo rm -rf /var/lib/apt/lists/* || return
}
