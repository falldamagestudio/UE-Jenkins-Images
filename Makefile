.PHONY: build-controller-google-compute-engine-plugin build-controller-gcp-secrets-manager-credentials-provider-plugin build-controller-docker-image build-controller

.PHONY: build-swarm-agent-linux

.PHONY: build-ssh-agent-vm-linux

ifndef CONTROLLER_IMAGE_AND_TAG
CONTROLLER_IMAGE_AND_TAG:=controller:local
endif

ifndef LINUX_SWARM_AGENT_IMAGE_AND_TAG
LINUX_SWARM_AGENT_IMAGE_AND_TAG:=linux-swarm-agent:local
endif


build-controller-google-compute-engine-plugin:
	cd Docker/controller/google-compute-engine-plugin && mvn install --no-transfer-progress

build-controller-gcp-secrets-manager-credentials-provider-plugin:
	cd Docker/controller/gcp-secrets-manager-credentials-provider-plugin && mvn install --no-transfer-progress

build-controller-docker-image:
	cd Docker/controller && docker build -f Dockerfile -t "$(CONTROLLER_IMAGE_AND_TAG)" .

build-controller: build-controller-google-compute-engine-plugin build-controller-gcp-secrets-manager-credentials-provider-plugin build-controller-docker-image

build-swarm-agent-linux:
	docker build -f Docker/agents/linux/swarm-agent/Dockerfile -t "$(LINUX_SWARM_AGENT_IMAGE_AND_TAG)" .

build-ssh-agent-vm-linux:
	./Scripts/Linux/linux-vm-image-builder.sh \
	VMs/agents/linux/ssh-agent/build.pkr.hcl \
	"$(GOOGLE_CLOUD_PROJECT_ID)" \
	"$(GOOGLE_CLOUD_ZONE)" \
	"$(LINUX_SSH_AGENT_VM_IMAGE_NAME)"
