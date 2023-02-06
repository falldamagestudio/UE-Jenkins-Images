FROM jenkins/agent:3085.vc4c6977c075a-4@sha256:a99d4873742f340661dba59b86e0f89209b0e49236206f9d437ede3546547cb5

USER root

# In order to install Plastic SCM client on debian 11 we need to add debian 10 repositories using workaround
# provided here https://plasticscmsupport.zendesk.com/hc/en-us/articles/360013103159-How-to-Install-Plastic-GUI-in-Ubuntu-19-10-and-later-
RUN echo deb http://deb.debian.org/debian/ buster main>/etc/apt/sources.list.d/buster-oldlibs.list

# Install Plastic SCM client

RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates wget gnupg --no-install-recommends \
    && echo "deb https://www.plasticscm.com/plasticrepo/stable/debian/ ./" | tee /etc/apt/sources.list.d/plasticscm-stable.list \
    && wget https://www.plasticscm.com/plasticrepo/stable/debian/Release.key --quiet -O - | apt-key add - \
    && apt-get update \
    && apt-get install -y plasticscm-client-core --no-install-recommends \
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

USER jenkins

RUN wget https://repo.jenkins-ci.org/artifactory/releases/org/jenkins-ci/plugins/swarm-client/3.39/swarm-client-3.39.jar -O swarm-client.jar

COPY --chown=jenkins:jenkins ./run_swarm_agent.sh /home/jenkins/run_swarm_agent.sh

RUN chmod ugo+x /home/jenkins/run_swarm_agent.sh

RUN mkdir /home/jenkins/agent/remoting

ENTRYPOINT [ "/home/jenkins/run_swarm_agent.sh" ]
