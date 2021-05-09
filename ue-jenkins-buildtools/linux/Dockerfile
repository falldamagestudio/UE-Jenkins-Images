FROM ubuntu

# Create user/group for jenkins user
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group} \
    && useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user}

# Disable interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install our build prerequisites
RUN \
	apt-get update && apt-get install -y --no-install-recommends \
		build-essential \
		ca-certificates \
		curl \
		git \
		jq \
		python3 \
		python3-dev \
		python3-pip \
		shared-mime-info \
		tzdata \
		unzip \
		xdg-user-dirs \
		zip && \
	rm -rf /var/lib/apt/lists/*

USER jenkins
