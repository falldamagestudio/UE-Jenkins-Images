FROM jenkins/jenkins:2.293-jdk11@sha256:439516c825946e9252a0b65049a3bfc500df8d599a57be9bfce08213c837170a

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

ADD plugins-with-dependencies.txt /usr/share/jenkins/ref/plugins-with-dependencies.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins-with-dependencies.txt --latest false --verbose
