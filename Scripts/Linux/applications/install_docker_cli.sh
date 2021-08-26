#!/bin/bash

function install_docker_cli () {
    apt-get update
    apt-get install -y apt-transport-https lsb-release curl ca-certificates gpg --no-install-recommends
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce-cli --no-install-recommends

    apt-get clean
    rm -rf /var/lib/apt/lists/*
}
