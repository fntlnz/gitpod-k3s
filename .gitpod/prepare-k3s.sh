#!/bin/bash

script_dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "Waiting for the ssh server to become available"

cd $script_dirname

function waitssh() {
  while ! nc -z 127.0.0.1 2222; do   
    sleep 0.1
  done
  ./ssh.sh "whoami" &>/dev/null
  if [ $? -ne 0 ]; then
    waitssh
  fi
}

waitssh

echo "ssh server available"

./ssh.sh "curl -sfL https://get.k3s.io | sh -"

mkdir -p ~/.kube
./scp.sh root@127.0.0.1:/etc/rancher/k3s/k3s.yaml ~/.kube/config

