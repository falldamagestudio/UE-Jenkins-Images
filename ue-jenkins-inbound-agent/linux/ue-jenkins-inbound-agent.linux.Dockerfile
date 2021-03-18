FROM jenkins/inbound-agent:4.6-1@sha256:19b6cb12bffa7e0d108fd66b14df96c819f729dc4ab7e0a43d53cbe154899b53

# Install Plastic SCM client

USER root

RUN apt-get update \
    && apt-get install -y apt-transport-https \
    && echo "deb https://www.plasticscm.com/plasticrepo/stable/debian/ ./" | tee /etc/apt/sources.list.d/plasticscm-stable.list \
    && wget https://www.plasticscm.com/plasticrepo/stable/debian/Release.key -O - | apt-key add - \
    && apt-get update \
    && apt-get install -y plasticscm-client-core

USER jenkins