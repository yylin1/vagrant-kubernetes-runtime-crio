# vagrant-kubernetes-runtime-crio

## Vagrant

If you want to try wlm-operator locally before updating your production cluster, use vagrant that will automatically install and configure all necessary software:

```
cd vagrant
vagrant up && vagrant ssh k8s-master
```

NOTE: vagrant up may take about 15 minutes to start as k8s cluster will be installed from scratch.
