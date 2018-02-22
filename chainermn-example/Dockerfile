FROM everpeace/kube-openmpi:0.2.0-cuda8.0

ARG NCCL_PACKAGE_VERSION="2.1.4-1+cuda8.0"
ARG CUPY_VERSION="4.0.0b3"
ARG CHAINER_VERSION="4.0.0b3"
ARG CHAINER_MN_VERSION="1.2.0"
ARG NVIDIA_REPO_URL="http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/nvidia-machine-learning-repo-ubuntu1604_1.0.0-1_amd64.deb"

RUN wget $NVIDIA_REPO_URL && \
    dpkg -i nvidia-machine-learning-repo-ubuntu1604_1.0.0-1_amd64.deb && \
    rm nvidia-machine-learning-repo-ubuntu1604_1.0.0-1_amd64.deb && \
    apt-get update && \
    apt-get install -yq --no-install-recommends \
      libnccl-dev=${NCCL_PACKAGE_VERSION} libnccl2=${NCCL_PACKAGE_VERSION} \
      python3-dev python3-pip python3-setuptools python3-wheel && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
      python3-dev python3-pip python3-setuptools python3-wheel && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN pip3 install -v --no-cache-dir cupy==$CUPY_VERSION
RUN pip3 install -v --no-cache-dir \
  chainer==$CHAINER_VERSION \
  chainermn==$CHAINER_MN_VERSION
