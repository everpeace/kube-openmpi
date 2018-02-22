ARG UBUNTU_BASED_BASE_IMAGE
FROM $UBUNTU_BASED_BASE_IMAGE

MAINTAINER Shingo OMURA <https://github.com/everpeace>

ARG OPENMPI_VERSION

ARG WITH_CUDA="false"
ARG S6_OVERLAY_VERSION="1.21.2.2"

# Disable prompts from apt.
ENV DEBIAN_FRONTEND noninteractive

# install ssh and basic dependencies
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
      locales wget ca-certificates ssh build-essential && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

#
# install s6-overlay
#
RUN set -x && \
    # fetch s6-overlay archive and signature
    wget -O s6.tgz \
      https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz && \
    wget -O s6.sig \
      https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz.sig && \
    # gpg verification
    export GNUPGHOME="$(mktemp -d)" && \
    wget -O - https://keybase.io/justcontainers/key.asc | gpg --import && \
    gpg --batch --verify s6.sig s6.tgz && \
    # extract s6-overlay archive
    tar -xzf s6.tgz -C / && \
    # cleanup
    rm -r "$GNUPGHOME" s6.sig s6.tgz

#
# install openmpi
#
RUN echo "WITH_CUDA=$WITH_CUDA"
RUN cd /tmp && \
  wget -q https://www.open-mpi.org/software/ompi/v$(echo $OPENMPI_VERSION | sed -e s'/\(.*\)\.[0-9]/\1/')/downloads/openmpi-$OPENMPI_VERSION.tar.bz2 && \
  tar -xjf openmpi-$OPENMPI_VERSION.tar.bz2 && \
  cd /tmp/openmpi-$OPENMPI_VERSION && \
  if [ "$WITH_CUDA" = "true" ]; then export WITH_CUDA_OPT="--with-cuda"; else export WITH_CUDA_OPT=""; fi && \
  echo "WITH_CUDA_OPT=$WITH_CUDA_OPT" && \
  ./configure --prefix=/usr $WITH_CUDA_OPT && \
  make -j2 && \
  make install && \
  rm -r /tmp/openmpi-$OPENMPI_VERSION

# Create ssh user(openmpi) and setup ssh key dir
# - defualt ssh_config and sshd_config will be placed with s6
#   see rootfs/etc/ssh
# - ssh identity file and authorized key file was modified to /ssh-key/_user_
#   in /etc/ssh/sshd_config,ssh_config.  Please see rootfs/etc/ssh/
# - ssh keys for ssh user(openmpi) is NOT provisioned here.
#   ssh key dir is defined as volume.
ARG USER=openmpi
ARG NB_UID=1000
ARG NB_GID=1000
RUN addgroup --gid $NB_GID openmpi
RUN adduser -q --gecos "" --disabled-password --uid $NB_UID --gid $NB_GID $USER
RUN mkdir -p /ssh-key/$USER && chown -R $USER:$USER /ssh-key/$USER
VOLUME /ssh-key/$USER

ENV HOME /home/$USER
RUN mkdir -p $HOME && chown $USER:$USER $HOME && chmod 755 $HOME
VOLUME $HOME

COPY rootfs /

# check if open mpi was successfully built with cuda support.
RUN if [ "$WITH_CUDA" = "true" ]; then \
  if ! ompi_info --parsable --all | grep -q "mpi_built_with_cuda_support:value:true" ; then \
    exit 1; \
  fi; fi;

EXPOSE 22
CMD ["/init"]
