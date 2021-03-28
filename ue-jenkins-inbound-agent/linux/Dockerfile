FROM jenkins/inbound-agent:4.7-1-jdk11@sha256:1e787fd53c4d24ae69656b548ece42dcd7c4deb4580cfd00d72cc521ac1ddef7

# Install Plastic SCM client

USER root

RUN apt-get update \
    && apt-get install -y apt-transport-https \
    && echo "deb https://www.plasticscm.com/plasticrepo/stable/debian/ ./" | tee /etc/apt/sources.list.d/plasticscm-stable.list \
    && wget https://www.plasticscm.com/plasticrepo/stable/debian/Release.key -O - | apt-key add - \
    && apt-get update \
    && apt-get install -y plasticscm-client-core

USER jenkins
