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

    # ref: https://stackoverflow.com/questions/73397110/how-to-stop-ubuntu-pop-up-daemons-using-outdated-libraries-when-using-apt-to-i
    sudo sed -i "s|#\\$nrconf{restart} = 'i';|\\$nrconf{restart} = 'a';|g" /etc/needrestart/needrestart.conf

    # Change the source.list
    sudo apt-get update
    sudo apt-get install -y vim git cmake build-essential tcpdump tig jq socat bash-completion
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Install Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    export DOCKER_VERSION="5:24.0.5-1~ubuntu.22.04~jammy"
    sudo apt-get install -y docker-ce=${DOCKER_VERSION}
    sudo usermod -aG docker $USER

    git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
    bash ~/.bash_it/install.sh -s

    # Disable swap
    sudo swapoff -a && sudo sysctl -w vm.swappiness=0
    sudo sed '/vagrant--vg-swap/d' -i /etc/fstab

    # Install kubectl
    sudo apt-get update && sudo apt-get install -y apt-transport-https curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee --append /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubectl
    echo 'source <(kubectl completion bash)' >> ~/.bashrc

    # Install K9S
    curl -sS https://webi.sh/k9s | sh

    # Install KIND
    curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/download/v0.14.0/kind-$(uname)-amd64"
    chmod a+x ./kind
    sudo mv ./kind /usr/local/bin/kind

  
  SHELL

  config.vm.network :private_network, ip: "192.168.56.111"
  config.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--cpus", 2]
      v.customize ["modifyvm", :id, "--memory", 4096]
      v.customize ['modifyvm', :id, '--nicpromisc1', 'allow-all']
  end
end
