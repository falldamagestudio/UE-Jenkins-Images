FROM jenkins/jenkins:2.375.2@sha256:78f3794af6d1decbd6fff04ba457c2374c5d398b36fdd799aede54c5ec3c0270

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY Docker/controller/plugins-with-dependencies.txt /usr/share/jenkins/ref/plugins-with-dependencies.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins-with-dependencies.txt --latest false --verbose

USER root

# In order to install Plastic SCM client on debian 11 we need to add debian 10 repositories using workaround
# provided here https://plasticscmsupport.zendesk.com/hc/en-us/articles/360013103159-How-to-Install-Plastic-GUI-in-Ubuntu-19-10-and-later-
RUN echo deb http://deb.debian.org/debian/ buster main>/etc/apt/sources.list.d/buster-oldlibs.list

# Install Plastic SCM client

RUN apt-get update \
    && apt-get install -y apt-transport-https wget --no-install-recommends \
    && curl -fsSL https://www.plasticscm.com/plasticrepo/stable/debian/Release.key | gpg --dearmor --yes -o /usr/share/keyrings/plasticscm.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/plasticscm.gpg] https://www.plasticscm.com/plasticrepo/stable/debian/ ./" | tee /etc/apt/sources.list.d/plasticscm-stable.list \
    && apt-get update \
    && apt-get install -y plasticscm-client-core --no-install-recommends \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Install some tools

RUN apt-get update \
    && apt-get install -y coreutils curl jq openssl --no-install-recommends \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Bring all scripts into container

RUN mkdir /Docker \
    && mkdir /Scripts

COPY --chown=jenkins:jenkins Docker /Docker
COPY --chown=jenkins:jenkins Scripts /Scripts

USER jenkins

# Create settings folder for Plastic

RUN mkdir -m 775 /var/jenkins_home/.plastic4

# Replace the offical google-compute-engine plugin with a locally-built version

COPY Docker/controller/google-compute-engine-plugin/target/google-compute-engine.hpi /usr/share/jenkins/ref/plugins/google-compute-engine.jpi

# Replace the official gcp-secrets-manager-credentials-provider plugin with a locally-built version

COPY Docker/controller/gcp-secrets-manager-credentials-provider-plugin/target/gcp-secrets-manager-credentials-provider.hpi /usr/share/jenkins/ref/plugins/gcp-secrets-manager-credentials-provider.jpi

ENTRYPOINT [ "/usr/bin/tini", "--", "/Scripts/Linux/controller/docker_entrypoints/controller.sh" ]
