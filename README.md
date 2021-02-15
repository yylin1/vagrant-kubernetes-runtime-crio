# vagrant-kubernetes-runtime-crio

## Vagrant

If you want to try wlm-operator locally before updating your production cluster, use vagrant that will automatically install and configure all necessary software:

```
cd vagrant
vagrant up && vagrant ssh k8s-master
```

NOTE: vagrant up may take about 15 minutes to start as k8s cluster will be installed from scratch.

```
> $ vagrant ssh k8s-master
vagrant@k8s-master:~$ kubectl get no -o wide
NAME         STATUS   ROLES    AGE     VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
k8s-master   Ready    master   20m     v1.16.7   192.168.60.10   <none>        Ubuntu 18.04.5 LTS   4.15.0-112-generic   singularity://3.6.4
node-1       Ready    <none>   3m34s   v1.16.7   192.168.60.11   <none>        Ubuntu 18.04.5 LTS   4.15.0-112-generic   singularity://3.6.4
```
