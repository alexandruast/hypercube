# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV["LC_ALL"] = "en_US.UTF-8"
ENV["VAGRANT_DISABLE_VBOXSYMLINKCREATE"] = "1"

box = "bento/centos-7.5"

origin = {
  :type => "origin",
  :hostname => "origin",
  :ip => "192.168.169.170",
  :box => box,
  :memory => 500,
  :cpus => 2
}

kube_nodes = [
  {
    :type => "master",
    :hostname => "kube-master1",
    :ip => "192.168.169.201",
    :box => box,
    :memory => 500,
    :cpus => 2
  },
  {
    :type => "master",
    :hostname => "kube-master2",
    :ip => "192.168.169.202",
    :box => box,
    :memory => 500,
    :cpus => 2
  },
  {
    :type => "worker",
    :hostname => "kube-worker1",
    :ip => "192.168.169.211",
    :box => box,
    :memory => 1200,
    :cpus => 2
  },
  {
    :type => "worker",
    :hostname => "kube-worker2",
    :ip => "192.168.169.212",
    :box => box,
    :memory => 1200,
    :cpus => 2
  }
]

Vagrant.configure(2) do |config|
  
  kube_nodes.each do |machine|
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

  config.vm.define "origin" do |node|
    node.vm.box = origin[:box]
    node.vm.hostname = origin[:hostname]
    node.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
        vb.memory = origin[:memory]
        vb.cpus = origin[:cpus]
    end
    node.vm.network "private_network", ip: origin[:ip]
    node.vm.provision "shell", path: "./extras/vagrant-ssh-key.sh", privileged: false
    node.vm.provision "shell" do |s|
      s.path = "./extras/origin-bootstrap.sh"
      s.privileged = false
      s.args = [
        kube_nodes.to_json.to_s
      ]
    end
  end

end

