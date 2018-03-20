ARG KUBE_OPENMPI_CUDA_BASE_IMAGE
FROM $KUBE_OPENMPI_CUDA_BASE_IMAGE

ARG NCCL_PACKAGE_VERSION
ARG CUPY_PKG
ARG CUPY_VERSION
ARG CHAINER_VERSION
ARG CHAINER_MN_VERSION

RUN apt-get update && apt-get install -yq --no-install-recommends \
      python3-dev python3-pip python3-setuptools python3-wheel && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN apt-get update && apt-get install -yq --no-install-recommends \
      libnccl-dev=${NCCL_PACKAGE_VERSION} libnccl2=${NCCL_PACKAGE_VERSION} && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN pip3 install -v --no-cache-dir $CUPY_PKG==$CUPY_VERSION
RUN pip3 install -v --no-cache-dir \
  chainer==$CHAINER_VERSION \
  chainermn==$CHAINER_MN_VERSION
