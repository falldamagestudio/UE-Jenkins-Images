FROM debian:11.6-slim@sha256:d51d5c391d202d5e2e0294a9df6ff077ed40583b11831d347d418690da496c50

# Create user/group for jenkins user
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group} \
    && useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user} -l

# Ensure Jenkins user can switch to root using 'sudo'

#RUN apt-get update \
#    && apt-get -y install sudo

# Bring all scripts into container

RUN mkdir /Docker \
    && mkdir /Scripts

COPY --chown=jenkins:jenkins Docker /Docker
COPY --chown=jenkins:jenkins Scripts /Scripts

# Allow sudo without password

#RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
#RUN sudo echo blah

# Remainder of script runs using jenkins user

USER root

# Install software

RUN /Docker/agents/linux/swarm-agent/install_root.sh

USER jenkins

RUN /Docker/agents/linux/swarm-agent/install_user.sh

# COPY --chown=jenkins:jenkins ./run_swarm_agent.sh /home/jenkins/run_swarm_agent.sh
#
# RUN chmod ugo+x /home/jenkins/run_swarm_agent.sh
#
# RUN mkdir /home/jenkins/agent/remoting
#
# ENTRYPOINT [ "/home/jenkins/run_swarm_agent.sh" ]

ENTRYPOINT [ "/Scripts/Linux/agents/docker_entrypoints/swarm_agent.sh" ]
