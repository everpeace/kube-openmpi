
# Custom ChainerMN image example on kube-openmpi
This example shows how to make ChainerMN docker image extending kube-openmpi base image.  And how to use it.

__Please be advised ChainerMN base container image are provided at DockerHub already.  This is only for sample.__

## Step 1.  Build your docker image
[Dockerfile](Dockerfile) used `everpeace/kube-openmpi:0.7.0-cuda8.0` as base image. And installs:

- NCCL `2.1.4-1+cuda8.0`
- CuPy `4.0.0b3`
- Chainer `4.0.0b3`
- ChainerMN `1.2.0`

```
$ REPO=(your_org)/(your_registry_name):(your_tag)
$ docker build . -t $REPO
$ docker push $REPO
```

## Step2. Generate ssh keys and edit configuration
```
# generate temporary key
$ ../gen-ssh-key.sh

# edit your values.yaml
# please replace 'image.repository' and 'image.tag' with your pushed image.
$ $EDITOR values.yaml
```

## Step3. Deploy
```
$ MPI_CLUSTER_NAME=__CHANGE_ME__
$ KUBE_NAMESPACE=__CHANGE_ME_
$ helm template ../chart --namespace $KUBE_NAMESPACE --name $MPI_CLUSTER_NAME -f values.yaml -f ssh-key.yaml | kubectl -n $KUBE_NAMESPACE create -f -
```

## Step4. Run
_You can be ignored 'Unexpected end of /proc/mounts line`overlay....'.  Please refer to [here](https://devtalk.nvidia.com/default/topic/1027077/container-pytorch/-quot-unexpected-end-of-proc-mounts-line-overlay-quot-on-p3-8xlarge/post/5223924/#5223924)_

```
# wait until $MPI_CLUSTER_NAME-master is ready
$ kubectl get -n $KUBE_NAMESPACE po $MPI_CLUSTER_NAME-master
NAME           READY     STATUS    RESTARTS   AGE
MPI_CLUSTER_NAME-master   1/1       Running   0          17s

# You can run mpiexec now via 'kubectl exec'!
# hostfile is automatically generated and located '/kube-openmpi/generated/hostfile'
$ kubectl -n $KUBE_NAMESPACE exec -it $MPI_CLUSTER_NAME-master -- mpiexec --allow-run-as-root \
  --hostfile /kube-openmpi/generated/hostfile \
  --display-map -n 2 -npernode 1 \
  python3 /chainermn-examples/mnist/train_mnist.py -g
Warning: Permanently added 'MPI_CLUSTER_NAME-worker-0,172.23.36.171' (ECDSA) to the list of known hosts.
Warning: Permanently added 'MPI_CLUSTER_NAME-worker-1,172.23.36.38' (ECDSA) to the list of known hosts.
 Data for JOB [28697,1] offset 0

 ========================   JOB MAP   ========================

 Data for node: MPI_CLUSTER_NAME-worker-0  Num slots: 8    Max slots: 0    Num procs: 1
        Process OMPI jobid: [28697,1] App: 0 Process rank: 0 Bound: socket 0[core 0[hwt 0-1]]:[BB/../../..][../../../..]

 Data for node: MPI_CLUSTER_NAME-worker-1  Num slots: 8    Max slots: 0    Num procs: 1
        Process OMPI jobid: [28697,1] App: 0 Process rank: 1 Bound: socket 0[core 0[hwt 0-1]]:[BB/../../..][../../../..]

 =============================================================
==========================================
Num process (COMM_WORLD): 2
Using GPUs
Using hierarchical communicator
Num unit: 1000
Num Minibatch-size: 100
Num epoch: 20
==========================================
epoch       main/loss   validation/main/loss  main/accuracy  validation/main/accuracy  elapsed_time
Unexpected end of /proc/mounts line `overlay / overlay rw,relatime,lowerdir=/var/lib/docker/overlay2/l/UNJN7WML5VB67GZI2C4GR77VJU:/var/lib/docker/overlay2/l/X3SWZTQ7PBMI6SFQQOYVWIW76Z:/var/lib/docker/overlay2/l/DHOJ5NNKETXKCXTPC643JBWPKF:/var/lib/docker/overlay2/l/U6GTZTDX5NPZZS6T3VI2CUH5OY:/var/lib/docker/overlay2/l/K3WGBUGMBI7QFN25T3W7E3DZXG:/var/lib/docker/overlay2/l/TEJH26S5SNGTRKBYMB5XSVKUNM:/var/lib/docker/overlay2/l/TATGQREE7UIRJ2XVPJFCFT6LVZ:/var/lib/docker/overlay2/l/53LU4L3PHZGHYZVAKUL2B6SVN4:/var/lib/docker/overlay2/l/4N2FFIIRA7HPB'
...
1           0.224002    0.102322              0.9335         0.9695                    17.1341
2           0.0733692   0.0672879             0.977967       0.9765                    24.7188
3           0.0462234   0.0652903             0.985134       0.9795                    32.04
4           0.0303526   0.0639791             0.990867       0.9805                    39.42
5           0.0252077   0.079451              0.991667       0.9775                    46.8614
...
20          0.00531046  0.105093              0.998267       0.9799                    160.794
```


## Step5. Tear Down

```
$ helm template ../chart --namespace $KUBE_NAMESPACE --name $MPI_CLUSTER_NAME -f values.yaml -f ssh-key.yaml | kubectl -n $KUBE_NAMESPACE delete -f -
```
