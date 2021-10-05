FROM openjdk:11-jdk-bullseye

ARG VERSION=3.28

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

ARG AGENT_WORKDIR=/home/${user}/agent

# Create jenkins user/group

RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user}

# Fetch swarm client

RUN apt-get update && apt-get install git-lfs && rm -rf /var/lib/apt/lists/*
RUN curl --create-dirs -fsSLo /usr/share/${user}/swarm-client.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${VERSION}/swarm-client-${VERSION}.jar \
  && chmod 755 /usr/share/${user} \
  && chmod 644 /usr/share/${user}/swarm-client.jar

USER ${user}

# Create agent workdir

ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}

WORKDIR /home/${user}

USER root

# Install agent wrapper script

COPY swarm-agent.sh /usr/local/bin/swarm-agent.sh
RUN chmod +x /usr/local/bin/swarm-agent.sh

ENTRYPOINT ["/usr/local/bin/swarm-agent.sh"]

# Install Docker CLI

RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates lsb-release curl gnupg --no-install-recommends \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
            $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli --no-install-recommends \
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# In order to install Plastic SCM client on debian 11 we need to add debian 10 repositories using workaround
# provided here https://plasticscmsupport.zendesk.com/hc/en-us/articles/360013103159-How-to-Install-Plastic-GUI-in-Ubuntu-19-10-and-later-
RUN echo deb http://deb.debian.org/debian/ buster main>/etc/apt/sources.list.d/buster-oldlibs.list

# Install Plastic SCM client

RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates wget gnupg --no-install-recommends \
    && echo "deb https://www.plasticscm.com/plasticrepo/stable/debian/ ./" | tee /etc/apt/sources.list.d/plasticscm-stable.list \
    && wget https://www.plasticscm.com/plasticrepo/stable/debian/Release.key --quiet -O - | apt-key add - \
    && apt-get update \
    && apt-get install -y plasticscm-client-core --no-install-recommends \
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

USER ${user}
