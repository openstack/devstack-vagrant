#!/bin/bash

set -o xtrace

openrc=/home/stack/devstack/openrc
source $openrc admin

if is_service_enabled n-api; then
    for user in "admin demo"; do
        source $openrc $user
        nova keypair-add --pub-key /home/stack/.ssh/authorized_keys default
    done

    source $openrc admin

    nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
    nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
fi
