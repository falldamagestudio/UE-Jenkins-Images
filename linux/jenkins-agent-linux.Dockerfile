FROM jenkins/agent:latest@sha256:93386d22c7f729992e3ad78dfe5281346b5b3db136684a51d55083329768fc36

# Install Plastic SCM client

USER root

RUN apt-get update \
    && apt-get install -y apt-transport-https \
    && echo "deb https://www.plasticscm.com/plasticrepo/stable/debian/ ./" | tee /etc/apt/sources.list.d/plasticscm-stable.list \
    && wget https://www.plasticscm.com/plasticrepo/stable/debian/Release.key -O - | apt-key add - \
    && apt-get update \
    && apt-get install -y plasticscm-client-core

USER jenkins