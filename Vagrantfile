# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.network "private_network", ip: "192.168.0.99"
  config.vm.synced_folder "/storage/Movies", "/movies"
  config.vm.synced_folder "/storage/TV Shows", "/tv"
  config.vm.synced_folder "/storage/Home Videos", "/homevideos"
	
  config.vm.provider "virtualbox" do |vb|
	vb.name = "Media Server"
	vb.memory = "1024"
	vb.cpus = "4"
  end
end
