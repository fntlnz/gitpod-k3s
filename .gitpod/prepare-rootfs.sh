#!/bin/bash

set -euo pipefail

img_url="https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.tar.gz"

script_dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
outdir="${script_dirname}/_output/rootfs"

rm -Rf $outdir
mkdir -p $outdir

curl -L -o "${outdir}/rootfs.tar.gz" $img_url

cd $outdir

tar -xvf rootfs.tar.gz

qemu-img resize bionic-server-cloudimg-amd64.img +20G

netconf="
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: yes
"

# networking setup
sudo virt-customize -a bionic-server-cloudimg-amd64.img \
--run-command 'resize2fs /dev/sda' \
--root-password password:root \
--run-command "echo '${netconf}' > /etc/netplan/01-net.yaml" \
--copy-in /lib/modules/5.4.0-1044-gke:/lib/modules \
--run-command "sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config" \
--run-command "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config" \
--run-command "ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key;
               ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key;
               ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key;"

# mark as ready
touch rootfs-ready.lock

echo "k3s development environment is ready"

