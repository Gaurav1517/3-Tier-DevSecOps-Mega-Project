#!/bin/bash

set -e  # Exit immediately if a command fails
set -x  # Print commands for debugging

# Update system & install pre-requsite
sudo apt-get update -y
sudo apt-get install -y wget vim git unzip tar

# --------------------------
# Install Java (OpenJDK 21)
# --------------------------
sudo apt-get install -y fontconfig openjdk-21-jre
java -version

# --------------------------
# Install Jenkins
# --------------------------
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y jenkins

# Start & enable Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# --------------------------
# Install Docker
# --------------------------
sudo apt-get install -y ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start & enable Docker
sudo systemctl enable docker
sudo systemctl start docker

# Add Jenkins user to Docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins  # Optional

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
# Install Trivy
# --------------------------
sudo apt-get install -y wget gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
  gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | \
  sudo tee /etc/apt/sources.list.d/trivy.list

sudo apt-get update -y
sudo apt-get install -y trivy

# --------------------------
# Install gitleaks
# --------------------------
sudo apt-get install -y gitleaks
