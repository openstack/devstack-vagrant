#!/bin/bash

set -o xtrace

openrc=/home/stack/devstack/openrc
pubkey_file=/home/stack/.ssh/authorized_keys

echo "Running local.sh"

source "$openrc"

if is_service_enabled n-api; then
    for user in admin demo; do
        source "$openrc" "$user" "$user"
        nova keypair-add --pub-key "$pubkey_file" default
        nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
        nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
    done
fi
