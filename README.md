
# kube-openmpi: Open MPI jobs on Kubernetes

kube-openmpi provides mainly two things:
- Kubernetes manifest template (powered by [Helm](https://github.com/kubernetes/helm)) to run open mpi jobs on kubernetes cluster. See `chart` directory for details.
- [base docker images on DockerHub](https://hub.docker.com/r/everpeace/kube-openmpi/) to build your custom docker images.  Currently we provide only ubuntu 16.04 based imaages.  To support distributed deep learning workloads, we provides cuda based images, too.  Supported tags are below:

# Supported tags of kube-openmpi base images
- Plain Ubuntu based: `2.1.2-16.04-0.5.1` / `0.5.1`
  - naming convention: `$(OPENMPI_VERSION)-$(UBUNTU_IMAGE_TAG)-$(KUBE_OPENMPI_VERSION)`
    - `$(UBUNTU_IMAGE_TAG)` refers to tags of [ubuntu](https://hub.docker.com/_/ubuntu/)
- Cuda (with cuDNN) based :
  - cuda8: `2.1.2-8.0-cudnn7-devel-ubuntu16.04-0.5.1` / `0.5.1-cuda8`
  - cuda9: `2.1.2-9.0-cudnn7-devel-ubuntu16.04-0.5.1` / `0.5.1-cuda9`
  - naming convention is `$(OPENMPI_VERSION)-$(CUDA_IMAGE_TAG)-$(KUBE_OPENMPI_VERSION)`
    - `$(CUDA_IMAGE_TAG)` refers to tags of [nvidia/cuda](https://hub.docker.com/r/nvidia/cuda/)

# Quick Start
## Requirements
- kubectl: follow [the installation step](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://github.com/kubernetes/helm) client: follow [the installatin step](https://docs.helm.sh/using_helm/#installing-the-helm-client).
- Kubernetes cluster ([minikube](https://github.com/kubernetes/minikube) is super-handy for local test.)


## Generate ssh keys and edit configuration
```
# generate temporary key
$ ./gen-ssh-key.sh

# edit your values.yaml
$ $EDITOR values.yaml
```

## Deploy
```
$ MPI_CLUSTER_NAME=__CHANGE_ME__
$ KUBE_NAMESPACE=__CHANGE_ME_
$ helm template chart --namespace $KUBE_NAMESPACE --name $MPI_CLUSTER_NAME -f values.yaml -f ssh-key.yaml | kubectl -n $KUBE_NAMESPACE create -f -
```

## Run
```
# wait until $MPI_CLUSTER_NAME-master is ready
$ kubectl get -n $KUBE_NAMESPACE po $MPI_CLUSTER_NAME-master

# You can run mpiexec now via 'kubectl exec'!
# hostfile is automatically generated and located '/kube-openmpi/generated/hostfile'
$ kubectl -n $KUBE_NAMESPACE exec -it $MPI_CLUSTER_NAME-master -- mpiexec --allow-run-as-root \
  --hostfile /kube-openmpi/generated/hostfile \
  --display-map -n 4 -npernode 1 \
  sh -c 'echo $(hostname):hello'
 Data for JOB [43686,1] offset 0

 ========================   JOB MAP   ========================

 Data for node: MPI_CLUSTER_NAME-worker-0        Num slots: 2    Max slots: 0    Num procs: 1
        Process OMPI jobid: [43686,1] App: 0 Process rank: 0 Bound: UNBOUND

 Data for node: MPI_CLUSTER_NAME-worker-1        Num slots: 2    Max slots: 0    Num procs: 1
        Process OMPI jobid: [43686,1] App: 0 Process rank: 1 Bound: UNBOUND

 Data for node: MPI_CLUSTER_NAME-worker-2        Num slots: 2    Max slots: 0    Num procs: 1
        Process OMPI jobid: [43686,1] App: 0 Process rank: 2 Bound: UNBOUND

 Data for node: MPI_CLUSTER_NAME-worker-3        Num slots: 2    Max slots: 0    Num procs: 1
        Process OMPI jobid: [43686,1] App: 0 Process rank: 3 Bound: UNBOUND

 =============================================================
MPI_CLUSTER_NAME-worker-1:hello
MPI_CLUSTER_NAME-worker-2:hello
MPI_CLUSTER_NAME-worker-0:hello
MPI_CLUSTER_NAME-worker-3:hello
```

## Scale Up/Down your cluster
MPI workers forms [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/). So, you can scale up or down the cluster.

```
# scale workers from 4 to 3
$ kubectl -n $KUBE_NAMESPACE scale statefulsets $MPI_CLUSTER_NAME-worker --replicas=3
statefulset "MPI_CLUSTER_NAME-worker" scaled

# Then you can mpiexec again
# hostfile will be updated automatically every 15 seconds in default
$ kubectl -n $KUBE_NAMESPACE exec -it $MPI_CLUSTER_NAME-master -- mpiexec --allow-run-as-root \
  --hostfile /kube-openmpi/generated/hostfile \
  --display-map -n 3 -npernode 1 \
  sh -c 'echo $(hostname):hello'
...
MPI_CLUSTER_NAME-worker-0:hello
MPI_CLUSTER_NAME-worker-2:hello
MPI_CLUSTER_NAME-worker-1:hello
```

## Tear Down

```
$ helm template chart --namespace $KUBE_NAMESPACE --name $MPI_CLUSTER_NAME -f values.yaml -f ssh-key.yaml | kubectl -n $KUBE_NAMESPACE delete -f -
```

# Use your own custom docker image
please edit `image` section in `values.yaml`

```
image:
  repository: yourname/kube-openmpi-based-custom-image
  tag: latest
```

It expects that your custom image is based on our base image ([everpeace/kube-openmpi](https://hub.docker.com/r/everpeace/kube-openmpi/)) and does NOT change any ssh/sshd configurations define in `image/Dockerfile` on your custom image.

Please refer to [ChainerMN Example](chainermn-example/README.md) for details.

# Inject your code to your containers from Github
kube-openmpi supports to import your codes hosted by github into your containers.  To do it, please edit `appCodesToSync` section in `values.yaml`.  You can define multiple github repositories.

```
appCodesToSync:
- name: your-app-name
  gitRepo: https://github.com/org/your-app-name.git
  gitBranch: master
  fetchWaitSecond: "120"
  mountPath: /repo
```

# Run kube-openmpi cluster as non-root user
At default, kube-openmpi runs your mpi cluster as root user.  However, from security standpoint, you might want to run your mpi-cluster as non-root user.  There is two way to achieve this.

## Use default `openmpi` user and group
[kube-openmpi base docker images on DockerHub](https://hub.docker.com/r/everpeace/kube-openmpi/) ships such normal user `openmpi` with `uid=1000`/`gid=1000`.  To make the user run your mpi-cluster,  edit your `values.yaml` to specify SecurityContext like below:

```
# values.yaml
...
mpiMaster:
  securityContext:
    runAsUser: 1000
    fsGroup: 1000
...
mpiWorkers:
  securityContext:
    runAsUser: 1000
    fsGroup: 1000
```

Then you can run `mpiexec` as `openmpi` user.  You would need to tear down and re-deploy your mpi-cluster if you had kube-openmpi cluster already.

```
$ kubectl -n $KUBE_NAMESPACE exec -it $MPI_CLUSTER_NAME-master -- mpiexec \
  --hostfile /kube-openmpi/generated/hostfile \
  --display-map -n 4 -npernode 1 \
  sh -c 'echo $(hostname):hello'
...
```

## Use your own custom user with custom uid/gid
You need to build your own custom base image because the custom user with your desired uid/gid must exists(embedded) in the docker image.  To do this, just run `make` with several options below.

```
$ cd images
$ make REPOSITORY=<your_org>/<your_repo> SSH_USER=<username> SSH_UID=<uid> SSH_GID=<gid>
```

This creates ubuntu based image, cuda8(cudnn7) image and cuda9(cudnn7) image.

And then, set the `image` in your `values.yaml` and set your uid/gid to `runAsUser`/`fsGroup` as the previous section.


## Release Notes
### __0.5.1__
- kubernetes manifests:
  - support user defined `volumes`/`volumeMounts`
  - kube-openmpi managed volume names changed.
- Documents
  - make `Run` step simpler. Changed to use `kubectl exec -it -- mpiexec` directly.

### __0.5.0__
- docker images:
  - `root` can ssh to both mpi-master and mpi-workers when containers run as root
- kubernetes manifests:
  - now mpi cluster runs as `root` at default
  - you can use `openmpi` user as before by setting `runAsUser`/`fsGroup` in `values.yaml`
  - you don't need to dig a tunnel to use `mpiexec` command!
  - documented how to use your custom user with custom uid/gid

### __0.4.0__
- docker images:
  - added `orte_keep_fqdn_hostnames=t` to `openmpi-mca-params.conf`
- kubernetes manifests:
  - now you don't need `CustomPodDNS` feature gate!!
  - `bootstrap` job was removed
  - `hostfile-updater` was introduced.  Now you can scale up/down your mpi cluster dynamically!
    - It runs next to `mpi-master` pod as a side-car container.
  - The path of auto generated `hostfile` was moved to `/kube-openmpi/generated/hostfile`

### __0.3.0__
- docker images:
  - removed s6-overlay init process and introduced self-managed sshd script to support `securityContext` (e.g. `securityContext.runAs`) (#1).
- kubernetes manifests:
  - supported custom `securityContext` (#1)
  - improved mpi-cluster cleanup process
  - fixed broken network-policy maniefst

### __0.2.0__
- docker images:
  - fixed cuda-aware openMPI installation script. added ensure `mca:mpi:base:param:mpi_built_with_cuda_support:value:true` when cuda based image was built.  You can NOT use open MPI with CUDA on `0.1.0`.  So, please use `0.2.0`.
- kubernetes manifests:
  - fixed `resources` in `values.yaml` was ignored.
  - now `workers` can resolve `master` in DNS.

### __0.1.0__
- initial release


# TODO
- [ ] automate the process (create kube-openmpi commnd?)
- [ ] document chart parameters
- [ ] add additional persistent volume claims
