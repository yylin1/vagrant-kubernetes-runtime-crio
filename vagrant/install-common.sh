#!/usr/bin/env bash

# install dependencies, libs and tools
export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get update
sudo -E apt-get install -y build-essential libssl-dev uuid-dev libgpgme11-dev libseccomp-dev pkg-config squashfs-tools vim 

# install go
export VERSION=1.13.1 OS=linux ARCH=amd64
wget -q -O /tmp/go${VERSION}.${OS}-${ARCH}.tar.gz https://dl.google.com/go/go${VERSION}.${OS}-${ARCH}.tar.gz
sudo tar -C /usr/local -xzf /tmp/go${VERSION}.${OS}-${ARCH}.tar.gz
rm /tmp/go${VERSION}.${OS}-${ARCH}.tar.gz

# configure environment
export GOPATH=${HOME}/go
export PATH=${PATH}:/usr/local/go/bin:${GOPATH}/bin
mkdir ${GOPATH}

cat >> ~/.bashrc <<EOF
export GOPATH=${GOPATH}
export PATH=${PATH}
alias k=kubectl
EOF

# install singularity
SINGULARITY_REPO="https://github.com/sylabs/singularity"
export VERSION=3.6.4
wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz -O ${HOME}
tar -xzf ${HOME}/singularity-${VERSION}.tar.gz
cd ${HOME}/singularity && ./mconfig && cd ./builddir &&  make && sudo make install

# install singularity-cri
SINGULARITY_CRI_REPO="https://github.com/sylabs/singularity-cri"
git clone ${SINGULARITY_CRI_REPO} ${HOME}/singularity-cri
cd ${HOME}/singularity-cri && make && sudo make install

# install wlm-operator
SINGULARITY_WLM_OPERATOR_REPO="https://github.com/sylabs/wlm-operator"
git clone ${SINGULARITY_WLM_OPERATOR_REPO} ${HOME}/wlm-operator

# set up CNI config
sudo mkdir -p /etc/cni/net.d

# set up sycri service
sudo sh -c 'cat > /etc/systemd/system/sycri.service <<EOF
[Unit]
Description=Singularity-CRI
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=30
User=root
Group=root
ExecStart=${HOME}/singularity-cri/bin/sycri -v 2
EOF'
sudo systemctl start sycri
sudo systemctl status sycri

# install k8s
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
export KUBE_VERSION="1.16.7"
sudo -E apt-get install -y kubelet=${KUBE_VERSION}-00 kubeadm=${KUBE_VERSION}-00 kubectl=${KUBE_VERSION}-00



# configure crictl
sudo touch /etc/crictl.yaml
sudo chown vagrant:vagrant /etc/crictl.yaml
cat > /etc/crictl.yaml << EOF
runtime-endpoint: unix:///var/run/singularity.sock
image-endpoint: unix:///var/run/singularity.sock
timeout: 10
debug: false
EOF

# configure system network config
sudo modprobe br_netfilter
sudo sysctl -w net.bridge.bridge-nf-call-iptables=1
sudo sysctl -w net.ipv4.ip_forward=1
