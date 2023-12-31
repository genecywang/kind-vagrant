# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.box_version ='202303.13.0'
  config.vm.hostname = 'k8s-dev'
  config.vm.define vm_name = 'k8s'

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    set -e -x -u
    export DEBIAN_FRONTEND=noninteractive
    export KIND_VERSION="v0.20.0"
    export DOCKER_VERSION="5:24.0.5-1~ubuntu.22.04~jammy"

    # ref: https://stackoverflow.com/questions/73397110/how-to-stop-ubuntu-pop-up-daemons-using-outdated-libraries-when-using-apt-to-i
    sudo sed -i "s|#\\$nrconf{restart} = 'i';|\\$nrconf{restart} = 'a';|g" /etc/needrestart/needrestart.conf

    # Change the source.list
    sudo apt-get update
    sudo apt-get install -y vim git cmake build-essential tcpdump tig jq socat bash-completion golang-cfssl
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Install Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce=${DOCKER_VERSION}
    sudo usermod -aG docker $USER

    git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
    bash ~/.bash_it/install.sh -s
    git clone https://github.com/genecywang/kind-vagrant.git

    # Disable swap
    sudo swapoff -a && sudo sysctl -w vm.swappiness=0
    sudo sed '/vagrant--vg-swap/d' -i /etc/fstab

    # Install kubectl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee --append /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubectl
    echo 'source <(kubectl completion bash)' >> ~/.bashrc

    # Install KIND
    curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-$(uname)-amd64"
    chmod a+x ./kind
    sudo mv ./kind /usr/local/bin/kind
    sudo kind create cluster --config kind-vagrant/kind.yaml
    sudo kind export kubeconfig
    sudo mv /root/.kube $HOME/.kube 
    sudo chown $(id -u):$(id -g) -R $HOME/.kube

    # Install K9S
    curl -sS https://webi.sh/k9s | sh
    sudo cp .local/bin/k9s /usr/local/bin/k9s 

    # Install Helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    bash get_helm.sh

    # Install Kustomize
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
    sudo mv kustomize /usr/local/bin/kustomize 

    kubectl apply -R -f kind-vagrant/metrics-server

    sudo sysctl -w fs.inotify.max_user_watches=2099999999
    sudo sysctl -w fs.inotify.max_user_instances=2099999999
    sudo sysctl -w fs.inotify.max_queued_events=2099999999

    echo 'export KUBECONFIG="$HOME/.kube/config"' >> ~/.bashrc
  SHELL

  config.vm.network :private_network, ip: "192.168.56.111"
  config.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--cpus", 2]
      v.customize ["modifyvm", :id, "--memory", 4096]
      v.customize ['modifyvm', :id, '--nicpromisc1', 'allow-all']
      v.customize ['modifyvm', :id, '--natpf1', 'k8s-api,tcp,127.0.0.1,44443,192.168.56.111,44443']
  end
end