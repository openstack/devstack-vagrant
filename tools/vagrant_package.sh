#!/bin/bash

# vagrant_clean.sh - clean the vagrant box to the point where you
# can safely take a snapshot for local caching

vagrant ssh manager -c "sudo su - stack -c 'cd ~/devstack && ./clean.sh'"
vagrant ssh manager -c "sudo sed -i '/api/d' /etc/hosts"
vagrant ssh manager -c "echo '127.0.0.1 localhost' | sudo tee -a /etc/hosts"

VBOX_ID=$(VBoxManage list vms | grep 'devstack-vagrant_manager' | awk '{print $2}')
NAME=devstack-vagrant-`date +%Y%m%d`
vagrant package --base $VBOX_ID --output $NAME.box $NAME
