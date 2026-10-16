#!/bin/bash
#
## Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

VERSION_STRING=5:26.0.0-1~ubuntu.24.04~noble

sudo apt install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo useradd -m -G docker rke

sudo  mkdir -p /home/rke/.ssh
sudo  chmod 700 /home/rke/.ssh
sudo  touch /home/rke/.ssh/authorized_keys
sudo  chmod 600 /home/rke/.ssh/authorized_keys
sudo chown -R rke:rke /home/rke
