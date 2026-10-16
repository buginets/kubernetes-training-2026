#!/bin/bash
#


read -p "Enter master IP: " master_ip
read -p "Enter worker1 IP: " worker1_ip
read -p "Enter worker2 IP: " worker2_ip

pubkey=$(cat ~/.ssh/id_ed25519.pub)
vms_ip=("$master_ip" "$worker1_ip" "$worker2_ip")
function install_rke() {
 
	 wget https://github.com/rancher-archives/rke/releases/download/v1.8.14/rke_linux-amd64

	mv rke_linux-amd64 rke
	chmod +x rke
	sudo mv rke /usr/local/bin
}


function install_kubectl() {

	 curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	 chmod +x kubectl
	 sudo mv kubectl /usr/local/bin
	 alias k=kubectl
}

#Function for docker

function docker() {
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
}
#Fucntion for VMS preparation
#
function prepare_vms() {
	for ip in "${vms_ip[@]}"
	do 
		scp vm.sh ubuntu@$ip:
		ssh ubuntu@$ip bash vm.sh
		ssh ubuntu@$ip "echo '$pubkey' | sudo tee -a /home/rke/.ssh/authorized_keys "

	done


}

#Function for cluster.yml file
#
function create_cluster_file() {
	cp cluster.yml.template cluster.yml
	sed -i "s/MASTER_IP/$master_ip/" cluster.yml
	sed -i "s/WORKER1_IP/$worker1_ip/" cluster.yml
	sed -i "s/WORKER2_IP/$worker2_ip/" cluster.yml



}

#Function for cluster
#
function create_cluster() {
	rke up
	sudo mkdir ~/.kube
	sudo mv kube_config_cluster.yml ~/.kube/config
	kubectl get nodes
}
# Function for SC
#
function create_sc(){
	kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml

	 kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

}

install_rke

install_kubectl

# docker

prepare_vms

create_cluster_file

create_cluster

create_sc


