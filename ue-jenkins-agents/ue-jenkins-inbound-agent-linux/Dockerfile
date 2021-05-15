FROM jenkins/inbound-agent:4.7-1-jdk11@sha256:1e787fd53c4d24ae69656b548ece42dcd7c4deb4580cfd00d72cc521ac1ddef7

USER root

# Install Docker CLI

RUN apt-get update \
    && apt-get install -y apt-transport-https lsb-release \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
            $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli

# Install Plastic SCM client

RUN apt-get update \
    && apt-get install -y apt-transport-https \
    && echo "deb https://www.plasticscm.com/plasticrepo/stable/debian/ ./" | tee /etc/apt/sources.list.d/plasticscm-stable.list \
    && wget https://www.plasticscm.com/plasticrepo/stable/debian/Release.key -O - | apt-key add - \
    && apt-get update \
    && apt-get install -y plasticscm-client-core

USER jenkins
