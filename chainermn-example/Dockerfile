FROM everpeace/kube-openmpi:0.5.2-cuda8.0

ARG NCCL_PACKAGE_VERSION="2.1.4-1+cuda8.0"
ARG CUPY_VERSION="4.0.0b4"
ARG CHAINER_VERSION="4.0.0b4"
ARG CHAINER_MN_VERSION="1.2.0"

RUN apt-get update && apt-get install -yq --no-install-recommends \
      python3-dev python3-pip python3-setuptools python3-wheel && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN apt-get update && apt-get install -yq --no-install-recommends \
    libnccl-dev=${NCCL_PACKAGE_VERSION} libnccl2=${NCCL_PACKAGE_VERSION} && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN pip3 install -v --no-cache-dir cupy-cuda80==$CUPY_VERSION
RUN pip3 install -v --no-cache-dir \
  chainer==$CHAINER_VERSION \
  chainermn==$CHAINER_MN_VERSION
