KUBE_OPENMPI_VERSION ?= 0.5.1
REPOSITORY ?= everpeace/kube-openmpi

OPENMPI_VERSION ?= 2.1.2

UBUNTU_REPOSITORY ?= ubuntu
UBUNTU_TAG ?= 16.04
UBUNTU_IMAGE ?= $(REPOSITORY):$(OPENMPI_VERSION)-$(UBUNTU_TAG)-$(KUBE_OPENMPI_VERSION)
UBUNTU_ALIAS ?= $(REPOSITORY):$(KUBE_OPENMPI_VERSION)

CUDA_REPOSITORY ?= nvidia/cuda
CUDA8_BASE_IMAGE_TAG ?= 8.0-cudnn7-devel-ubuntu16.04
CUDA8_IMAGE  ?= $(REPOSITORY):$(OPENMPI_VERSION)-$(CUDA8_BASE_IMAGE_TAG)-$(KUBE_OPENMPI_VERSION)
CUDA8_ALIAS  ?= $(REPOSITORY):$(KUBE_OPENMPI_VERSION)-cuda8.0

CUDA9_BASE_IMAGE_TAG ?= 9.1-cudnn7-devel-ubuntu16.04
CUDA9_IMAGE  ?= $(REPOSITORY):$(OPENMPI_VERSION)-$(CUDA9_BASE_IMAGE_TAG)-$(KUBE_OPENMPI_VERSION)
CUDA9_ALIAS  ?= $(REPOSITORY):$(KUBE_OPENMPI_VERSION)-cuda9.1

SSH_USER ?= openmpi
SSH_UID ?= 1000
SSH_GID ?= 1000

.PHONY: build
build: ubuntu_image cuda8_image cuda9_image

ubuntu_image:
	docker build \
		--build-arg UBUNTU_BASED_BASE_IMAGE=$(UBUNTU_REPOSITORY):$(UBUNTU_TAG) \
		--build-arg OPENMPI_VERSION=$(OPENMPI_VERSION) \
		--build-arg WITH_CUDA="false" \
		--build-arg SSH_USER=$(SSH_USER) \
		--build-arg SSH_UID=$(SSH_UID) \
		--build-arg SSH_GID=$(SSH_GID) \
		-t $(UBUNTU_IMAGE) \
		. && \
		docker tag $(UBUNTU_IMAGE) $(UBUNTU_ALIAS)

cuda8_image:
	docker build \
		--build-arg UBUNTU_BASED_BASE_IMAGE=$(CUDA_REPOSITORY):$(CUDA8_BASE_IMAGE_TAG) \
		--build-arg OPENMPI_VERSION=$(OPENMPI_VERSION) \
		--build-arg WITH_CUDA="true" \
		--build-arg SSH_USER=$(SSH_USER) \
		--build-arg SSH_UID=$(SSH_UID) \
		--build-arg SSH_GID=$(SSH_GID) \
		-t $(CUDA8_IMAGE) \
		. && \
		docker tag $(CUDA8_IMAGE) $(CUDA8_ALIAS)

cuda9_image:
	docker build \
		--build-arg UBUNTU_BASED_BASE_IMAGE=$(CUDA_REPOSITORY):$(CUDA9_BASE_IMAGE_TAG) \
		--build-arg OPENMPI_VERSION=$(OPENMPI_VERSION) \
		--build-arg WITH_CUDA="true" \
		--build-arg SSH_USER=$(SSH_USER) \
		--build-arg SSH_UID=$(SSH_UID) \
		--build-arg SSH_GID=$(SSH_GID) \
		-t $(CUDA9_IMAGE) \
		. && \
		docker tag $(CUDA9_IMAGE) $(CUDA9_ALIAS)


publish:
	docker push $(CUDA8_IMAGE) && docker push $(CUDA8_ALIAS) && \
	docker push $(CUDA9_IMAGE) && docker push $(CUDA9_ALIAS) && \
	docker push $(UBUNTU_IMAGE) && docker push $(UBUNTU_ALIAS)
