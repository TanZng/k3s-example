echo -e "\n> Install docker"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install ca-certificates curl gnupg lsb-release net-tools -y

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

echo -e "\n> Post Install"
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R

sudo systemctl enable docker.service
sudo systemctl enable containerd.service
echo -e "\n> Docker Swarm (should be dead but ok)"

# For the "master"
IP_MASTER=$(ip -f inet addr show eth1 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p')
docker swarm init --advertise-addr IP_MASTER
SWARM_TOKEN=$(docker swarm join-token -q worker)
echo -e "\n RUN THIS ON NODES:"
echo -e "docker swarm join --token $SWARM_TOKEN $IP_MASTER:2377"
echo "export IP_MASTER=$(ip -f inet addr show eth1 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p')" >> $HOME/.bashrc
echo "export SWARM_TOKEN=$(docker swarm join-token -q worker)" >> $HOME/.bashrc
