# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Require a recent version of vagrant otherwise some have reported errors setting host names on boxes
Vagrant.require_version ">= 1.6.3"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # The number of minions to provision
  num_minion = (ENV['NUM_MINIONS'] || 0).to_i

  # ip configuration
  master_ip = "10.245.1.2"
  minion_ip_base = "10.245.2."
  minion_ips = num_minion.times.collect { |n| minion_ip_base + "#{n+2}" }
  minion_ips_str = minion_ips.join(",")

  config.vm.box = "ubuntu/trusty64"

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
    v.memory = 1536
    v.cpus = 1
  end

  config.vm.define "master" do |config|
    config.vm.provision "shell", inline: "/vagrant/vagrant/provision-master.sh #{master_ip} #{num_minion} #{minion_ips_str}"
    config.vm.network "private_network", ip: master_ip
    config.vm.hostname = "salt-master"
    config.vm.synced_folder "vagrant/srv/salt", "/srv/salt"
    config.vm.synced_folder "cassandra", "/srv/salt/cassandra"
    config.vm.synced_folder "vagrant/srv/pillar", "/srv/pillar"
  end

  num_minion.times do |n|
    config.vm.define "minion-#{n+1}" do |minion|
      minion_index = n+1
      minion_ip = minion_ips[n]
      minion.vm.provision "shell", inline: "/vagrant/vagrant/provision-minion.sh #{master_ip} #{num_minion} #{minion_ips_str} #{minion_ip} #{minion_index}"
      minion.vm.network "private_network", ip: minion_ip
      minion.vm.hostname = "salt-minion-#{minion_index}"
    end
  end

end
