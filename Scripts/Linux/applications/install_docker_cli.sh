#!/bin/bash

function install_docker_cli () {
    ${SUDO} apt-get update || return
    ${SUDO} apt-get install -y apt-transport-https lsb-release curl ca-certificates gpg --no-install-recommends || return
    { curl -fsSL https://download.docker.com/linux/debian/gpg || return ; } | { ${SUDO} gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg || return ; }
    { echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" || return ; } | { ${SUDO} tee /etc/apt/sources.list.d/docker.list > /dev/null || return ; }
    ${SUDO} apt-get update || return
    ${SUDO} apt-get install -y docker-ce-cli --no-install-recommends || return

    ${SUDO} apt-get clean || return
    ${SUDO} rm -rf /var/lib/apt/lists/* || return
}
