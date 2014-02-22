devstack-vagrant
================

This is an attempt to build an easy to use tool to bring up a 2 node
devstack environment for local testing using Vagrant + Puppet.

It is *almost* fully generic, but still hard codes a few things about
my environment for lack of a way to figure out how to do this
completely generically (puppet templates currently hate me under
vagrant).

This will build a vagrant cluster that is L2 bridged to the interface
that you specify in `` local_config.rb``. All devstack guests (2nd
level) will also be L2 bridged to that network as well. That means
that once you bring up this environment you will be able to ssh
stack@api (or whatever your hostname is) from any machines on your
network.

Vagrant Setup
------------------------

Install vagrant & virtual box

Configure a base ``~/.vagrant.d/Vagrantfile`` to set your VM size. If you
have enough horsepower you should make the file something like:

    VAGRANTFILE_API_VERSION = "2"

    Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
        config.vm.provider :virtualbox do |vb|

             # Use VBoxManage to customize the VM. For example to change memory:
             vb.customize ["modifyvm", :id, "--memory", "8192"]
             vb.customize ["modifyvm", :id, "--cpus", "4"]
         end
    end

You can probably get away with less cpus, and 4096 MB of memory, but
the above is recommended size.


Local Setup
--------------------
Copy ``local_config.rb.sample`` to ``local_config.rb`` and provide the
hostnames you want, and password hash (not password), and sshkey for
the stack user.

Then run vagrant up.

On a 32 GB Ram, 4 core i7 haswell, on an SSD, with Fios, this takes
25 - 30 minutes. So it's not quick. However it is repeatble.


What you should get
-----------------------------------
A 2 node devstack that includes cirros, fedora 20, and ubuntu 12.04
cloud images populated in glance.

Default security group with ssh and ping opened up.

Installation of the stack user ssh key as the default keypair.
