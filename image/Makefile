KUBE_OPENMPI_VERSION ?= 0.7.0
REPOSITORY ?= everpeace/kube-openmpi

OPENMPI_VERSION ?= 2.1.2

# Args for SSH Uer embedded in container images
SSH_USER ?= openmpi
SSH_UID ?= 1000
SSH_GID ?= 1000

# Args for Base Image
UBUNTU_REPOSITORY ?= ubuntu
UBUNTU_TAG ?= 16.04
UBUNTU_IMAGE ?= $(REPOSITORY):$(OPENMPI_VERSION)-$(UBUNTU_TAG)-$(KUBE_OPENMPI_VERSION)
UBUNTU_ALIAS ?= $(REPOSITORY):$(KUBE_OPENMPI_VERSION)

# Args for CUDA with Cudnn7 Image
CUDA_REPOSITORY ?= nvidia/cuda
CUDA80_BASE_IMAGE_TAG ?= 8.0-cudnn7-devel-ubuntu16.04
CUDA80_IMAGE  ?= $(REPOSITORY):$(OPENMPI_VERSION)-$(CUDA80_BASE_IMAGE_TAG)-$(KUBE_OPENMPI_VERSION)
CUDA80_ALIAS  ?= $(REPOSITORY):$(KUBE_OPENMPI_VERSION)-cuda8.0

CUDA90_BASE_IMAGE_TAG ?= 9.0-cudnn7-devel-ubuntu16.04
CUDA90_IMAGE  ?= $(REPOSITORY):$(OPENMPI_VERSION)-$(CUDA90_BASE_IMAGE_TAG)-$(KUBE_OPENMPI_VERSION)
CUDA90_ALIAS  ?= $(REPOSITORY):$(KUBE_OPENMPI_VERSION)-cuda9.0

CUDA91_BASE_IMAGE_TAG ?= 9.1-cudnn7-devel-ubuntu16.04
CUDA91_IMAGE  ?= $(REPOSITORY):$(OPENMPI_VERSION)-$(CUDA91_BASE_IMAGE_TAG)-$(KUBE_OPENMPI_VERSION)
CUDA91_ALIAS  ?= $(REPOSITORY):$(KUBE_OPENMPI_VERSION)-cuda9.1

# Args for ChainerMN Image
# nvidia/cuda:9.0 or 9.1 contains nccl 2.1.15-1 already.
NCCL_CUDA80_PACKAGE_VERSION ?= 2.1.4-1
NCCL_CUDA90_PACKAGE_VERSION ?= 2.1.15-1
NCCL_CUDA91_PACKAGE_VERSION ?= $(NCCL_CUDA90_PACKAGE_VERSION)
CUPY_CUDA80_PKG ?= cupy-cuda80
CUPY_CUDA90_PKG ?= cupy-cuda90
CUPY_CUDA91_PKG ?= cupy
CUPY_VERSION ?= 4.0.0b4
CHAINER_VERSION ?= 4.0.0b4
CHAINER_MN_VERSION ?= 1.2.0

CHAINER_MN_CUDA80_IMAGE ?= $(REPOSITORY):$(OPENMPI_VERSION)-$(CUDA80_BASE_IMAGE_TAG)-$(KUBE_OPENMPI_VERSION)-nccl$(NCCL_CUDA80_PACKAGE_VERSION)-chainer$(CHAINER_VERSION)-chainermn$(CHAINER_MN_VERSION)
CHAINER_MN_CUDA80_ALIAS ?= $(REPOSITORY):$(KUBE_OPENMPI_VERSION)-cuda8.0-nccl$(NCCL_CUDA80_PACKAGE_VERSION)-chainer$(CHAINER_VERSION)-chainermn$(CHAINER_MN_VERSION)

CHAINER_MN_CUDA90_IMAGE ?= $(REPOSITORY):$(OPENMPI_VERSION)-$(CUDA90_BASE_IMAGE_TAG)-$(KUBE_OPENMPI_VERSION)-nccl$(NCCL_CUDA90_PACKAGE_VERSION)-chainer$(CHAINER_VERSION)-chainermn$(CHAINER_MN_VERSION)
CHAINER_MN_CUDA90_ALIAS ?= $(REPOSITORY):$(KUBE_OPENMPI_VERSION)-cuda9.0-nccl$(NCCL_CUDA90_PACKAGE_VERSION)-chainer$(CHAINER_VERSION)-chainermn$(CHAINER_MN_VERSION)

CHAINER_MN_CUDA91_IMAGE ?= $(REPOSITORY):$(OPENMPI_VERSION)-$(CUDA91_BASE_IMAGE_TAG)-$(KUBE_OPENMPI_VERSION)-nccl$(NCCL_CUDA91_PACKAGE_VERSION)-chainer$(CHAINER_VERSION)-chainermn$(CHAINER_MN_VERSION)
CHAINER_MN_CUDA91_ALIAS ?= $(REPOSITORY):$(KUBE_OPENMPI_VERSION)-cuda9.1-nccl$(NCCL_CUDA91_PACKAGE_VERSION)-chainer$(CHAINER_VERSION)-chainermn$(CHAINER_MN_VERSION)


.PHONY: build
build: ubuntu_image cuda80_image cuda90_image cuda91_image chainermn_cuda80_image chainermn_cuda90_image chainermn_cuda91_image

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

cuda80_image:
	docker build \
		--build-arg UBUNTU_BASED_BASE_IMAGE=$(CUDA_REPOSITORY):$(CUDA80_BASE_IMAGE_TAG) \
		--build-arg OPENMPI_VERSION=$(OPENMPI_VERSION) \
		--build-arg WITH_CUDA="true" \
		--build-arg SSH_USER=$(SSH_USER) \
		--build-arg SSH_UID=$(SSH_UID) \
		--build-arg SSH_GID=$(SSH_GID) \
		-t $(CUDA80_IMAGE) \
		. && \
		docker tag $(CUDA80_IMAGE) $(CUDA80_ALIAS)

cuda90_image:
	docker build \
		--build-arg UBUNTU_BASED_BASE_IMAGE=$(CUDA_REPOSITORY):$(CUDA90_BASE_IMAGE_TAG) \
		--build-arg OPENMPI_VERSION=$(OPENMPI_VERSION) \
		--build-arg WITH_CUDA="true" \
		--build-arg SSH_USER=$(SSH_USER) \
		--build-arg SSH_UID=$(SSH_UID) \
		--build-arg SSH_GID=$(SSH_GID) \
		-t $(CUDA90_IMAGE) \
		. && \
		docker tag $(CUDA90_IMAGE) $(CUDA90_ALIAS)

cuda91_image:
	docker build \
		--build-arg UBUNTU_BASED_BASE_IMAGE=$(CUDA_REPOSITORY):$(CUDA91_BASE_IMAGE_TAG) \
		--build-arg OPENMPI_VERSION=$(OPENMPI_VERSION) \
		--build-arg WITH_CUDA="true" \
		--build-arg SSH_USER=$(SSH_USER) \
		--build-arg SSH_UID=$(SSH_UID) \
		--build-arg SSH_GID=$(SSH_GID) \
		-t $(CUDA91_IMAGE) \
		. && \
		docker tag $(CUDA91_IMAGE) $(CUDA91_ALIAS)

chainermn_cuda80_image:
	docker build \
	  --build-arg KUBE_OPENMPI_CUDA_BASE_IMAGE=$(CUDA80_IMAGE) \
		--build-arg NCCL_PACKAGE_VERSION=$(NCCL_CUDA80_PACKAGE_VERSION)+cuda8.0 \
		--build-arg CUPY_PKG=$(CUPY_CUDA80_PKG) \
		--build-arg CUPY_VERSION=$(CUPY_VERSION) \
		--build-arg CHAINER_VERSION=$(CHAINER_VERSION) \
		--build-arg CHAINER_MN_VERSION=$(CHAINER_MN_VERSION) \
		-f Dockerfile.chainermn \
		-t $(CHAINER_MN_CUDA80_IMAGE) \
		. && \
		docker tag $(CHAINER_MN_CUDA80_IMAGE) $(CHAINER_MN_CUDA80_ALIAS)

chainermn_cuda90_image:
	docker build \
	  --build-arg KUBE_OPENMPI_CUDA_BASE_IMAGE=$(CUDA90_IMAGE) \
		--build-arg NCCL_PACKAGE_VERSION=$(NCCL_CUDA90_PACKAGE_VERSION)+cuda9.1 \
		--build-arg CUPY_PKG=$(CUPY_CUDA90_PKG) \
		--build-arg CUPY_VERSION=$(CUPY_VERSION) \
		--build-arg CHAINER_VERSION=$(CHAINER_VERSION) \
		--build-arg CHAINER_MN_VERSION=$(CHAINER_MN_VERSION) \
		-f Dockerfile.chainermn \
		-t $(CHAINER_MN_CUDA90_IMAGE) \
		. && \
		docker tag $(CHAINER_MN_CUDA90_IMAGE) $(CHAINER_MN_CUDA90_ALIAS)

chainermn_cuda91_image:
	docker build \
	  --build-arg KUBE_OPENMPI_CUDA_BASE_IMAGE=$(CUDA91_IMAGE) \
		--build-arg NCCL_PACKAGE_VERSION=$(NCCL_CUDA91_PACKAGE_VERSION)+cuda9.1 \
		--build-arg CUPY_PKG=$(CUPY_CUDA91_PKG) \
		--build-arg CUPY_VERSION=$(CUPY_VERSION) \
		--build-arg CHAINER_VERSION=$(CHAINER_VERSION) \
		--build-arg CHAINER_MN_VERSION=$(CHAINER_MN_VERSION) \
		-f Dockerfile.chainermn \
		-t $(CHAINER_MN_CUDA91_IMAGE) \
		. && \
		docker tag $(CHAINER_MN_CUDA91_IMAGE) $(CHAINER_MN_CUDA91_ALIAS)

publish:
	docker push $(CUDA80_IMAGE) && docker push $(CUDA80_ALIAS) && \
	docker push $(CUDA90_IMAGE) && docker push $(CUDA90_ALIAS) && \
	docker push $(CUDA91_IMAGE) && docker push $(CUDA91_ALIAS) && \
	docker push $(CHAINER_MN_CUDA80_IMAGE) && docker push $(CHAINER_MN_CUDA80_ALIAS) && \
	docker push $(CHAINER_MN_CUDA90_IMAGE) && docker push $(CHAINER_MN_CUDA90_ALIAS) && \
	docker push $(CHAINER_MN_CUDA91_IMAGE) && docker push $(CHAINER_MN_CUDA91_ALIAS) && \
	docker push $(UBUNTU_IMAGE) && docker push $(UBUNTU_ALIAS)
