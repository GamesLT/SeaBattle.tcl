# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# Params
domain="seabattle.test"
ip="192.168.201.65"

# Installs required plugins if not installed
if ARGV.include?('up') || ARGV.include?('reload')
  plugins = [
      'vagrant-docker-compose',
      'vagrant-hostmanager'
  ].select do |plugin|
    !Vagrant.has_plugin?(plugin)
  end.join(' ')
  if plugins.length > 0
    system 'vagrant plugin install ' + plugins
    system 'vagrant up'
    exit true
  end
end

# Configures machines
Vagrant.configure("2") do |config|
  config.vm.box = "envimation/ubuntu-xenial-docker"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = 2048
  end

  config.vm.network :private_network,
                    ip: ip
  config.vm.network :forwarded_port,
                    guest: 80,
                    host: 80,
                    host_ip: ip,
                    auto_correct: false

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.hostmanager.aliases = [
      domain
  ]

  config.vm.provision :docker
  config.vm.provision :docker_compose,
                      yml:
                          -"/vagrant/docker-compose.demo.yml",
                      rebuild: true,
                      project_name: "SeaBattle",
                      run: "always"
end
