FROM jenkins/jenkins:lts@sha256:3647dc7dcf43faf20a612465dc1aed6bf510893ff9724df4050604af80123b85

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

ADD plugins-with-dependencies.txt /usr/share/jenkins/ref/plugins-with-dependencies.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins-with-dependencies.txt --latest false --verbose
