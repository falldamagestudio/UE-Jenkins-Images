
.PHONY: local-linux-swarm-agent


local-linux-swarm-agent:
	docker build -f Docker/agents/linux/swarm-agent/Dockerfile -t linux-swarm-agent:local .

