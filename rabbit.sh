#!/bin/bash
echo -e "\n>Start k3s"

IP="10.114.0.2"
NET_INTERFACE=$(ifconfig | grep -E $IP -B 1 | grep -ohE ".*:" | sed s/.$//)

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=$IP --flannel-iface=$NET_INTERFACE" sh -s -

echo -e "\n> Make kubectl available"
mkdir -p $HOME/.kube
[[ -f $HOME/.kube/config ]] || touch $HOME/.kube/config
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && sudo chown $USER ~/.kube/config && sudo chmod 600 ~/.kube/config && export KUBECONFIG=~/.kube/config

echo -e "\n> Setting up local-path...\n"
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

echo -e "\n> Installing RabbitMQ Operator..."
echo -e "this might take a while...\n"
kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"

kubectl get all -n rabbitmq-system

echo -e "\n> Creating RabbitMQ Cluster..."
echo -e "this might take a while...\n"
kubectl apply -f ./k8s/rabbit-mq.yaml

kubectl get rabbitmqclusters.rabbitmq.com

while [[ $(kubectl get deployment -n rabbitmq-system rabbitmq-cluster-operator -o jsonpath="{.status.unavailableReplicas}" | jq) == 1 ]]; do
    echo -e "waiting operator...\n"
    sleep 30
done

# kubectl wait -n default --for=condition=ready svc --selector=app.kubernetes.io/part-of=rabbitmq --timeout=220s
while [[ $(kubectl get pods hello-world-server-0 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
    echo -e "waiting pod...\n"
   sleep 30
done


echo -e "\n\nAccess RabbitMQ in"
kubectl get ingress hello-world -o jsonpath='{.status.loadBalancer.ingress[0]}' | jq

username="$(kubectl get secret hello-world-default-user -o jsonpath='{.data.username}' | base64 --decode)"
echo -e "\nUsername: $username"
password="$(kubectl get secret hello-world-default-user -o jsonpath='{.data.password}' | base64 --decode)"
echo -e "Password: $password\n"


