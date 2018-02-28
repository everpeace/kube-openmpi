ARG UBUNTU_BASED_BASE_IMAGE
FROM $UBUNTU_BASED_BASE_IMAGE

MAINTAINER Shingo OMURA <https://github.com/everpeace>

ARG OPENMPI_VERSION

ARG WITH_CUDA="false"

# Disable prompts from apt.
ENV DEBIAN_FRONTEND noninteractive

# install ssh and basic dependencies
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
      locales wget ca-certificates ssh build-essential && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

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

# If the container run with custom uid
# the process can't provision users.
# So, we create bunch of users for specific user id range.
ARG SSH_UID_MIN
ARG SSH_UID_MAX
RUN for id in $(seq $SSH_UID_MIN $SSH_UID_MAX); do \
  addgroup --gid $id user_$id; \
  adduser -q --gecos "" --disabled-password --uid $id --gid $id user_$id; \
  mkdir -p /.sshd/user_$id; \
  chown user_$id:user_$id /.sshd/user_$id; \
  chmod 700 /.sshd/user_$id; \
  done

COPY rootfs /

# check if open mpi was successfully built with cuda support.
RUN if [ "$WITH_CUDA" = "true" ]; then \
  if ! ompi_info --parsable --all | grep -q "mpi_built_with_cuda_support:value:true" ; then \
    exit 1; \
  fi; fi;

EXPOSE 2022

# sshd can be run either by root or $SSH_USER
CMD ["/start_sshd.sh"]
