FROM jenkins/jenkins:2.285-jdk11@sha256:5a133a674ec0f233ae52c25f6ee6d7edb8d6bf314dc1c85e70e323157a2ad6ce

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

ADD plugins-with-dependencies.txt /usr/share/jenkins/ref/plugins-with-dependencies.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins-with-dependencies.txt --latest false --verbose
