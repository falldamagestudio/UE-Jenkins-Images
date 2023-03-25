FROM debian:11.6-slim@sha256:d51d5c391d202d5e2e0294a9df6ff077ed40583b11831d347d418690da496c50

# Create user/group for jenkins user
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group} \
    && useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user} -l

# Bring all scripts into container

RUN mkdir /Docker \
    && mkdir /Scripts

COPY --chown=jenkins:jenkins Docker /Docker
COPY --chown=jenkins:jenkins Scripts /Scripts

# Install software

USER root

RUN /Docker/agents/linux/swarm-agent/install_root.sh

USER jenkins

RUN /Docker/agents/linux/swarm-agent/install_user.sh

ENTRYPOINT [ "/Scripts/Linux/agents/docker_entrypoints/swarm_agent.sh" ]
