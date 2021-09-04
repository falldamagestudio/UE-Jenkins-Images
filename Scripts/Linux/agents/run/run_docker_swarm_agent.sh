#!/bin/bash

function run_docker_swarm_agent () {

    AGENT_IMAGE_URL_LINUX=$1
    JENKINS_URL=$2
    AGENT_USERNAME=$3
    AGENT_API_TOKEN=$4
    LABELS=$5
    AGENT_NAME=$6

    # Launch jenkins-agent container
    #
    # The mounts serve different purposes:
    # - /home/jenkins/.docker/config.json - allows pulling images from Google Artifact Registry from within the container
    # - /var/run/docker.sock - allows for interacting with the Docker daemon from within the container
    # - /home/jenkins/agent - allows for storing logs and .JAR cache somewhere that persists between host VM restarts
    # - /home/jenkins/worksapce - allows for storing build job workspace somewhere that persists between host VM restarts,
    #
    # All these mounts will also be used in any additional containers started by the build job,
    #   so all these resources will be accessible by the build job's own script logic;
    #   in theory, the build job only needs access to /home/jenkins/workspace but Jenkins offers no means
    #   for restricting which of these mounts will be present when the build job's logic runs

    docker \
        run \
        --detach \
        --rm \
        --name=jenkins-agent \
        --mount type=bind,source=/home/chronos/user/.docker/config.json,destination=/home/jenkins/.docker/config.json \
        --mount type=bind,source=/mnt/disks/persistent-disk/workspace,destination=/home/jenkins/workspace \
        --mount type=bind,source=/mnt/disks/persistent-disk/agent,destination=/home/jenkins/agent \
        --mount type=bind,source=/mnt/disks/persistent-disk/.plastic4,destination=/home/jenkins/.plastic4 \
        -v /var/run/docker.sock:/var/run/docker.sock \
        "${AGENT_IMAGE_URL_LINUX}" \
        -webSocket \
        -executors 1 \
        -labels "${LABELS}" \
        -mode exclusive \
        -master "${JENKINS_URL}" \
        -workDir /home/jenkins/agent \
        -username "${AGENT_USERNAME}" \
        -password "${AGENT_API_TOKEN}" \
        -disableClientsUniqueId \
        -deleteExistingClients \
        -failIfWorkDirIsMissing \
        -name "${AGENT_NAME}"
}