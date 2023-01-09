#!/bin/bash

docker compose up -d
docker build -t localhost:5000/go-hello-world .
docker push localhost:5000/go-hello-world

curl http://localhost:5000/v2/_catalog

curl -sfL https://get.k3s.io | sh -

echo -e "\nMake kubectl available"
mkdir -p $HOME/.kube
[[ -f $HOME/.kube/config ]] || touch $HOME/.kube/config
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && sudo chown $USER ~/.kube/config && sudo chmod 600 ~/.kube/config && export KUBECONFIG=~/.kube/config

sudo sh -c "
cat <<EOF >>/etc/rancher/k3s/registries.yaml
mirrors:
  localhost:
    endpoint:
      - http://localhost:5000
EOF
"

echo -e "\nRestarting k3s"
sudo systemctl restart k3s.service

echo -e "\nApply manifest"                                                                                 
kubectl apply -f ./k8s/deployment.yaml                                                                                                                                                                                                                                                                                                                                                                                                                                    
kubectl apply -f ./k8s/service.yaml
