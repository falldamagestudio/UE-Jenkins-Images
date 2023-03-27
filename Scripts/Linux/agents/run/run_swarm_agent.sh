#!/bin/bash

function run_swarm_agent () {

    # Jenkins agent writes all log messages to stderr. It has INFO/WARNING/SEVERE levels within the text lines printed.
    #
    # Example log output:
    # Mar 27, 2023 10:35:49 AM hudson.plugins.swarm.Client run
    # INFO: Connecting to Jenkins controller
    # Mar 27, 2023 10:35:49 AM hudson.plugins.swarm.Client run
    # INFO: Attempting to connect to http://controller:8080/
    # Mar 27, 2023 10:35:50 AM hudson.remoting.jnlp.Main createEngine
    # INFO: Setting up agent: controller-agent
    #
    # If these log messages are sent as-is to stderr, they result in priority level 3 entries (which show up as errors in GCP's Logs Explorer).
    #
    # To make these useful, we need to inspect the java.util.Logging log level in each message and prepend a Syslog/systemd priority level prefix:
    # - Prefix each line leading with 'INFO:' with <6>
    # - Prefix each line leading with 'WARNING:' with <5>
    # - Prefix each line leading with 'SEVERE:' with <3>
    # - Prefix each line leading with neither with <6>
    # Reference: https://docs.oracle.com/javase/7/docs/api/java/util/logging/Level.html
    # Reference: https://en.wikipedia.org/wiki/Syslog#Severity_level
    # Reference: http://0pointer.de/public/systemd-man/sd-daemon.html

    JENKINS_AGENT_FOLDER=$1
    JENKINS_FSROOT_FOLDER=$2
    AGENT_JAR_LOCATION=$3
    JENKINS_URL=$4
    AGENT_USERNAME=$5
    AGENT_API_TOKEN=$6
    LABELS=$7
    AGENT_NAME=$8

    java \
        -jar "${AGENT_JAR_LOCATION}" \
        -workDir "${JENKINS_AGENT_FOLDER}" \
        -master "${JENKINS_URL}" \
        -username "${AGENT_USERNAME}" \
        -password "${AGENT_API_TOKEN}" \
        -mode exclusive \
        -executors 1 \
        -labels "${LABELS}" \
        -webSocket \
        -disableClientsUniqueId \
        -deleteExistingClients \
        -failIfWorkDirIsMissing \
        -fsroot "${JENKINS_FSROOT_FOLDER}" \
        -name "${AGENT_NAME}" \
        2> >(sed -u "/^INFO: / { s/^/<6>/ ; b } ; /^WARNING: / { s/^/<5>/; b } ; /^SEVERE: / { s/^/<3>/; b } ; s/^/<6>/") \
        || return
}