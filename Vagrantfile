# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2" if not defined? VAGRANTFILE_API_VERSION

require 'yaml'
if File.file?('config.yaml')
  conf = YAML.load_file('config.yaml')
else
  raise "Configuration file 'config.yaml' does not exist."
end

def configure_vm(name, vm, conf)
  vm.hostname = conf["hostname_#{name}"] || name
  # we do an L2 bridge directly onto the physical network, which means
  # that your OpenStack hosts (manager, compute) are directly in the
  # same network as your physical host. Your OpenStack guests (2nd
  # level guests that you create in nova) will be also on the same L2,
  # however they will be in a different address space (10.0.0.0/24 by
  # default).
  #
  # :use_dhcp_assigned_default_route true is important to let your
  # guests actually route all the way out to the real internet.

  vm.network :public_network, :bridge => conf['bridge_int'], :use_dhcp_assigned_default_route => true
  vm.provider :virtualbox do |vb|
    # you need this for openstack guests to talk to each other
    vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
    # if specified assign a static MAC address
    if conf["mac_address_#{name}"]
      vb.customize ["modifyvm", :id, "--macaddress2", conf["mac_address_#{name}"]]
    end
  end

  # puppet provisioning
  vm.provision "puppet" do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path = "puppet/modules"
    puppet.manifest_file = "default.pp"
    puppet.options = "--verbose --debug"
    ## custom facts provided to Puppet
    puppet.facter = {
      ## tells default.pp that we're running in Vagrant
      "is_vagrant" => true,
      "is_compute" => (name != "manager"),
    }
    # add all the rest of the content in the conf file
    conf.each do |k, v|
      puppet.facter[k] = v
    end
  end

  if conf['setup_mode'] == "devstack"
    vm.provision "shell" do |shell|
      shell.inline = "sudo su - stack -c 'cd ~/devstack && ./stack.sh'"
    end
  end

  if conf['setup_mode'] == "grenade"
    vm.provision "shell" do |shell|
      shell.inline = "sudo su - stack -c 'cd ~/grenade && ./grenade.sh'"
    end
  end

end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Step 1: what's you base box that you are going to use
  #
  # - if you specify a local box_name on your system, we'll use that
  # - else we're going to use an upstream box from the cloud at 14.04 level
  # - lastly, let you override the url in case you have something cached locally
  #
  # The boot time is long for these, so I recommend that you convert to a local
  # version as soon as you can.
  if conf['box_name']
    config.vm.box = conf['box_name']
  else
    config.vm.box = 'ubuntu/trusty64'
  end
  if conf['box_url']
    config.vm.box_url = conf['box_url']
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  # NOTE(berendt): This solves the Ubuntu-specific Vagrant issue 1673.
  #                https://github.com/mitchellh/vagrant/issues/1673
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  config.vm.define "manager" do |manager|
    configure_vm("manager", manager.vm, conf)
    manager.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
    manager.vm.network "forwarded_port", guest: 6080, host: 6080, host_ip: "127.0.0.1"
  end

  if conf['hostname_compute']
    config.vm.define "compute" do |compute|
      configure_vm("compute", compute.vm, conf)
    end
  end

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  if conf['local_openstack_tree']
    config.vm.synced_folder conf['local_openstack_tree'], "/home/vagrant/openstack"
  end

end
