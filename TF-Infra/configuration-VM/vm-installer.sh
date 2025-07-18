#!/bin/bash

set -e  # Exit on error
set -x  # Print commands as they run

# Update system & install prerequisites
sudo apt-get update -y
sudo apt-get install -y wget vim git unzip tar curl gnupg software-properties-common lsb-release

# --------------------------
# Install AWS CLI
# --------------------------
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip
aws --version

# --------------------------
# Install Terraform
# --------------------------
# 1. Download and add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# 2. Add the HashiCorp repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

# 3. Update package index and install Terraform
sudo apt update && sudo apt install -y terraform
terraform -version

# --------------------------
# Install kubectl
# --------------------------
KUBECTL_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"

echo "$(<kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
rm kubectl kubectl.sha256

# --------------------------
# Install eksctl
# --------------------------
curl -sLO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz"
tar -xzf eksctl_$(uname -s)_amd64.tar.gz
sudo mv eksctl /usr/local/bin
rm eksctl_$(uname -s)_amd64.tar.gz
eksctl version
