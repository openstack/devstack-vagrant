#!/bin/bash

echo "Running local.sh"

set -o xtrace

openrc=/home/stack/devstack/openrc
authorized_keys_file=/home/stack/.ssh/authorized_keys

source "$openrc"

if is_service_enabled n-api; then
    # Extract valid public key into tmp file to work around the issue,
    # introduced by puppet adding comments in the beginning of authorized_keys
    pubkey_file=`mktemp`
    grep -vE '^\s*#' "$authorized_keys_file" | head -n 1 > "$pubkey_file"

    for user in admin demo; do
        source "$openrc" "$user" "$user"
        openstack keypair create --public-key "$pubkey_file" default
        openstack security group rule create --proto icmp --dst-port -1 --remote-ip 0.0.0.0/0 default
        openstack security group rule create --proto tcp --dst-port 22 --remote-ip 0.0.0.0/0 default
    done

    # Tmp file cleanup
    rm -f "$pubkey_file"
fi
