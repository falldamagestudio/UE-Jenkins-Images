FROM jenkins/jenkins:2.289.2-lts-jdk11@sha256:049ed8206529c5c6736741bdcb3c8f8c53ffec72eb84dfb8dc7a84c9bcaa1624

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY plugins-with-dependencies.txt /usr/share/jenkins/ref/plugins-with-dependencies.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins-with-dependencies.txt --latest false --verbose

USER root

# Install Plastic SCM client

RUN apt-get update \
    && apt-get install -y apt-transport-https wget --no-install-recommends \
    && echo "deb https://www.plasticscm.com/plasticrepo/stable/debian/ ./" | tee /etc/apt/sources.list.d/plasticscm-stable.list \
    && wget https://www.plasticscm.com/plasticrepo/stable/debian/Release.key --quiet -O - | apt-key add - \
    && apt-get update \
    && apt-get install -y plasticscm-client-core --no-install-recommends \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*


# Create settings folder for Plastic
#
# We're doing it here instead of letting Kubernetes' mounting of secrets create
#  the folder. Otherwise, if we let Kubernetes mount individual files into a
#  non-existent .plastic4 folder, then Kubernetes will create the folder with
#  permissions 755, and uid=0 / gid=jenkins. This means that the Jenkins controller
#  (which runs as uid=jenkins) will not be able to create new files in that folder.
# This, in turn results in some `cm` invocations failing, which results in error
#  messages like these when triggering a job in a Plasti repo:
#   ERROR: Unable to find Jenkinsfiles/build_game_linux_plastic_static.groovy from Plastic
#   SCM repository "UE-Jenkins-Game@ue_jenkins_buildsystem@cloud" path "/" smartbranch "/main"

RUN mkdir -m 775 /var/jenkins_home/.plastic4

USER jenkins

# Replace the offical google-compute-engine plugin with a locally-built version

COPY google-compute-engine-plugin/target/google-compute-engine.hpi /usr/share/jenkins/ref/plugins/google-compute-engine.jpi
