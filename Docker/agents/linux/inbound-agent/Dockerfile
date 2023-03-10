FROM jenkins/inbound-agent:4.10-3@sha256:87644be0a621aa6a11cc265b49f0ea2de96d3ec2ca39eb495f125940b05ee795

USER root

# Install Docker CLI

RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates lsb-release curl gnupg --no-install-recommends \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
            $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli --no-install-recommends \
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# In order to install Plastic SCM client on debian 11 we need to add debian 10 repositories using workaround
# provided here https://plasticscmsupport.zendesk.com/hc/en-us/articles/360013103159-How-to-Install-Plastic-GUI-in-Ubuntu-19-10-and-later-
RUN echo deb http://deb.debian.org/debian/ buster main>/etc/apt/sources.list.d/buster-oldlibs.list

# Install Plastic SCM client

RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates wget gnupg --no-install-recommends \
    && curl -fsSL https://www.plasticscm.com/plasticrepo/stable/debian/Release.key | gpg --dearmor --yes -o /usr/share/keyrings/plasticscm.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/plasticscm.gpg] https://www.plasticscm.com/plasticrepo/stable/debian/ ./" | tee /etc/apt/sources.list.d/plasticscm-stable.list \
    && apt-get update \
    && apt-get install -y plasticscm-client-core --no-install-recommends \
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

USER jenkins
