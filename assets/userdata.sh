#!/bin/bash

# ops routine
dnf -y update
dnf -y install nmap

# user's env
su -c "echo 'source <(kubectl completion bash)' >>~/.bashrc" ec2-user
su -c "echo 'alias k=kubectl' >>~/.bashrc" ec2-user
su -c "echo 'complete -o default -F __start_kubectl k' >>~/.bashrc" ec2-user

# kubectl bin
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.2/2024-07-12/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin &&cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH

# argocd bin
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

su -c "echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc" ec2-user
su -c "aws eks update-kubeconfig --region eu-central-1 --name dev-cloudos-cluster" ec2-user
su -c "kubectl create namespace argocd" ec2-user
su -c "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml" ec2-user
su -c "kubectl config set-context --current --namespace argocd" ec2-user

#kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
#kubectl port-forward svc/argocd-server -n argocd 8080:443 &
