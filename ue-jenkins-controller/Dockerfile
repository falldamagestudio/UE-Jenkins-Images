FROM jenkins/jenkins:2.289.2-lts-jdk11@sha256:049ed8206529c5c6736741bdcb3c8f8c53ffec72eb84dfb8dc7a84c9bcaa1624

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

ADD plugins-with-dependencies.txt /usr/share/jenkins/ref/plugins-with-dependencies.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins-with-dependencies.txt --latest false --verbose

USER root

# Install Plastic SCM client

RUN apt-get update \
    && apt-get install -y apt-transport-https wget \
    && echo "deb https://www.plasticscm.com/plasticrepo/stable/debian/ ./" | tee /etc/apt/sources.list.d/plasticscm-stable.list \
    && wget https://www.plasticscm.com/plasticrepo/stable/debian/Release.key -O - | apt-key add - \
    && apt-get update \
    && apt-get install -y plasticscm-client-core

USER jenkins

# Replace the offical google-compute-engine plugin with a locally-built version

ADD google-compute-engine-plugin/target/google-compute-engine.hpi /usr/share/jenkins/ref/plugins/google-compute-engine.jpi
