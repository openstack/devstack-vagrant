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
        nova keypair-add --pub-key "$pubkey_file" default
        nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
        nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
    done

    # Tmp file cleanup
    rm -f "$pubkey_file"
fi
