# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
if not VAGRANTFILE_API_VERSION
  VAGRANTFILE_API_VERSION = "2"
end

require './local_config.rb'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.define "manager" do |manager|
    manager.vm.box = "devstack-api"
    manager.vm.hostname = MANAGER_HOSTNAME

    manager.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.module_path = "puppet/modules"
      puppet.manifest_file = "default.pp"
      puppet.options = "--verbose --debug"
      ## custom facts provided to Puppet
      puppet.facter = {
        ## tells default.pp that we're running in Vagrant
        "is_vagrant" => true,
        "is_compute" => false,
        "stack_pass" => STACK_PASS,
        "stack_sshkey" => STACK_SSHKEY
      }
    end
  end

  config.vm.define "compute1" do |compute1|
    compute1.vm.box = "compute1"
    compute1.vm.hostname = COMPUTE1_HOSTNAME

    compute1.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.module_path = "puppet/modules"
      puppet.manifest_file = "default.pp"
      puppet.options = "--verbose --debug"
      ## custom facts provided to Puppet
      puppet.facter = {
        ## tells default.pp that we're running in Vagrant
        "is_vagrant" => true,
        "is_compute" => true,
        "stack_pass" => STACK_PASS,
        "stack_sshkey" => STACK_SSHKEY,
        "manager_hostname" => MANAGER_HOSTNAME
      }
    end
  end

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  #
  # We start with the Ubuntu 12.04 upstream image, which will work. However
  # building from this ever time is slow. So the recommended model is build
  # the manager once, and recapture that. You do have to nuke a bunch of
  # network config information to make that capture work (documentation TBD).

  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'
  # this lets you use a locally accessible version faster
  if BOX_URL
    config.vm.box_url = BOX_URL
  end

  # config.ssh.private_key_path = "/home/sdague/.ssh/id_rsa"
  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  #config.vm.network :forwarded_port, guest: 5000, host: 5000
  #config.vm.network :forwarded_port, guest: 8774, host: 8774

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network :private_network, ip: "192.168.33.20"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  config.vm.network :public_network, :bridge => BRIDGE_INT
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
  end

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  if LOCAL_OPENSTACK_TREE
    config.vm.synced_folder LOCAL_OPENSTACK_TREE, "/home/vagrant/openstack"
  end

end
