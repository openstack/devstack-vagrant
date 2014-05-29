# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
if not VAGRANTFILE_API_VERSION
  VAGRANTFILE_API_VERSION = "2"
end

require 'yaml'
conf = YAML.load(File.open('config.yaml'))

def configure_vm(name, vm, conf)
  vm.hostname = conf["#{name}_hostname"] or name

  # we do an L2 bridge directly onto the physical network, which means
  # that your OpenStack hosts (manager, compute1) are directly in the
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
    # allows for stable mac addresses
    if conf["#{name}_mac"]
      vb.customize ["modifyvm", :id, "--macaddress2", conf["#{name}_mac"]]
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
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.define "manager" do |manager|
    configure_vm("manager", manager.vm, conf)
  end

  if conf['compute1_hostname']
    config.vm.define "compute1" do |compute1|
      configure_vm("compute1", compute1.vm, conf)
    end
  end

  # You can either name a Vagrant box you have locally added and use
  # that as a starting point, or give a url from where the 'config.vm.box'
  # box will be fetched.
  #
  # We start with the Ubuntu 12.04 upstream image, which will work. However
  # building from this every time is slow. So the recommended model is build
  # the manager once, and recapture that. You do have to nuke a bunch of
  # network config information to make that capture work (documentation TBD).
  if conf['box_name']
    config.vm.box = conf['box_name']
  else
      config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'
      # this lets you use a locally accessible version faster
      if conf['box_url']
        config.vm.box_url = conf['box_url']
      end
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  #config.vm.network :forwarded_port, guest: 5000, host: 5000
  #config.vm.network :forwarded_port, guest: 8774, host: 8774

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
