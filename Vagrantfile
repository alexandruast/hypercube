# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV["LC_ALL"] = "en_US.UTF-8"
ENV["VAGRANT_DISABLE_VBOXSYMLINKCREATE"] = "1"

box = "bento/centos-7.5"

environment = {
  :kube_tools => [
    {
      :hostname => "origin",
      :ip => "192.168.169.170",
      :box => box,
      :memory => 500,
      :cpus => 2
    }
  ],
  :kube_masters => [
    {
      :hostname => "kube-master1",
      :ip => "192.168.169.201",
      :box => box,
      :memory => 500,
      :cpus => 2
    },
    {
      :hostname => "kube-master2",
      :ip => "192.168.169.202",
      :box => box,
      :memory => 500,
      :cpus => 2
    }
  ],
  :kube_workers => [
    {
      :hostname => "kube-worker1",
      :ip => "192.168.169.211",
      :box => box,
      :memory => 1200,
      :cpus => 2
    },
    {
      :hostname => "kube-worker2",
      :ip => "192.168.169.212",
      :box => box,
      :memory => 1200,
      :cpus => 2
    }  
  ]
}

Vagrant.configure(2) do |config|

  # provisioning kube masters
  environment[:kube_masters].each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = machine[:box]
      node.vm.hostname = machine[:hostname]
      node.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
        vb.memory = machine[:memory]
        vb.cpus = machine[:cpus]
      end  
      node.vm.network "private_network", ip: machine[:ip]
      node.vm.provision "shell", path: "./extras/vagrant-ssh-key.sh", privileged: false
    end
  end
  
  # provisioning kube workers
  environment[:kube_workers].each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = machine[:box]
      node.vm.hostname = machine[:hostname]
      node.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
        vb.memory = machine[:memory]
        vb.cpus = machine[:cpus]
      end  
      node.vm.network "private_network", ip: machine[:ip]
      node.vm.provision "shell", path: "./extras/vagrant-ssh-key.sh", privileged: false
    end
  end
  
  # provisioning kube tools
  environment[:kube_tools].each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = machine[:box]
      node.vm.hostname = machine[:hostname]
      node.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
        vb.memory = machine[:memory]
        vb.cpus = machine[:cpus]
      end  
      node.vm.network "private_network", ip: machine[:ip]
      node.vm.provision "shell", path: "./extras/vagrant-ssh-key.sh", privileged: false
      node.vm.provision "shell", inline: "echo '#{environment.to_json.to_s}' > environment.json", privileged: false
      node.vm.provision "shell", path: "./extras/#{machine[:hostname]}-bootstrap.sh", privileged: false
    end
  end

end

