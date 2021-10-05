FROM jenkins/inbound-agent:4.10-3@sha256:ed980b3451b9a3ee47047d55fe5926ee48a28d5b343b7c0af3d80c252df1c701

USER root

# Install Docker CLI

RUN apt-get update \
    && apt-get install -y apt-transport-https lsb-release --no-install-recommends \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
            $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli --no-install-recommends \
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Install Plastic SCM client

RUN apt-get update \
    && apt-get install -y apt-transport-https  --no-install-recommends \
    && echo "deb https://www.plasticscm.com/plasticrepo/stable/debian/ ./" | tee /etc/apt/sources.list.d/plasticscm-stable.list \
    && wget https://www.plasticscm.com/plasticrepo/stable/debian/Release.key --quiet -O - | apt-key add - \
    && apt-get update \
    && apt-get install -y plasticscm-client-core --no-install-recommends \
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

USER jenkins
