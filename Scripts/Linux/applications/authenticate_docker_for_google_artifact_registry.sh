#!/bin/bash

# Use JSON key-based authentication for Docker
#
# While we could rely on the application default credentials (using the instance's own service account) instead,
#   that would work on the host VM but not within the jenkins-agent container (the instance metadata service
#   is not available at 169.254.169.254 there). The simplest way for us to get Docker authentication to work
#   both on the host VM and within the container is to switch to JSON key authentication and then
#   mount the docker config file into the jenkins-agent container.

function authenticate_docker_for_google_artifact_registry () {

    LOCATION=$1
    ACCESS_KEY=$2

    { echo "${ACCESS_KEY}" || return ; } | { docker login -u _json_key --password-stdin "https://${LOCATION}-docker.pkg.dev" || return ; }
}
