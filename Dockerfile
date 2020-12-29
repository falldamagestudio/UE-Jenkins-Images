FROM ubuntu

# Disable interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install our build prerequisites
RUN \
	apt-get update && apt-get install -y --no-install-recommends \
		build-essential \
		ca-certificates \
		curl \
		git \
		python3 \
		python3-dev \
		python3-pip \
		shared-mime-info \
		tzdata \
		unzip \
		xdg-user-dirs \
		zip && \
	rm -rf /var/lib/apt/lists/*

