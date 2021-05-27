#!/bin/bash

set -euo pipefail

script_dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
rootfslock="${script_dirname}/_output/rootfs/rootfs-ready.lock"
k3sreadylock="${script_dirname}/_output/rootfs/k3s-ready.lock"

if test -f "${k3sreadylock}"; then
    exit 0
fi

cd $script_dirname

function waitssh() {
  while ! nc -z 127.0.0.1 2222; do   
    sleep 0.1
  done
  ./ssh.sh "whoami" &>/dev/null
  if [ $? -ne 0 ]; then
    sleep 1
    waitssh
  fi
}

function waitrootfs() {
  while ! test -f "${rootfslock}"; do
    sleep 0.1
  done
}

echo "Waiting for the rootfs to become available"
waitrootfs
echo "✅ rootfs available"

echo "Waiting for the ssh server to become available"
waitssh
echo "✅ ssh server available"

./ssh.sh "curl -sfL https://get.k3s.io | sh -"

mkdir -p ~/.kube
./scp.sh root@127.0.0.1:/etc/rancher/k3s/k3s.yaml ~/.kube/config

echo "✅ k3s server is ready"
kubectl get pods --all-namespaces

touch "${k3sreadylock}"
