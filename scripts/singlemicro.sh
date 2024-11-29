#!/bin/bash

# Create disks
lxc storage create disks zfs size=25GiB
lxc storage set disks volume.size 10GiB

lxc storage volume create disks local1 --type block

lxc storage volume create disks remote1 --type block size=5GiB

# Init nodes
lxc init ubuntu:24.04 micro1 --vm --config limits.cpu=4 --config limits.memory=4GiB

# Attach disks
lxc storage volume attach disks local1 micro1

# Create uplink network
lxc network create microbr0

# Attach networks
lxc config device add micro1 eth1 nic network=microbr0 name=eth1

# Start nodes
lxc start micro1

sleep 30

# Configure network
# cat << EOF > ./99-microcloud.yaml
# # MicroCloud requires a network interface that doesn't have an IP address
# network:
#     version: 2
#     ethernets:
#         enp6s0:
#             accept-ra: false
#             dhcp4: false
#             link-local: []
# EOF

lxc file push ~/utils/scripts/99-microcloud.yaml micro1/etc/netplan/

lxc exec micro1 -- sh -c "chmod 0600 /etc/netplan/99-microcloud.yaml"

lxc exec micro1 -- sh -c "netplan apply"

sleep 15

lxc file push ~/go/bin/lxd ~/go/bin/lxc ~/go/bin/lxd-agent micro1/root/

install_snaps() {
    local machine=$1

    lxc exec "${machine}" -- sh -c 'snap install microceph --channel=latest/edge --cohort="+"'
    lxc exec "${machine}" -- sh -c 'snap install microcloud --channel=2/edge --cohort="+"'
    lxc exec "${machine}" -- sh -c 'snap install microovn --channel=latest/edge --cohort="+"'
    lxc exec "${machine}" -- sh -c 'snap install lxd --channel=5.21/stable --cohort="+"'
}

install_snaps micro1

sideload_lxd() {
    local machine=$1
    lxc exec "${machine}" -- sudo mv ./lxd /var/snap/lxd/common/lxd.debug
    lxc exec "${machine}" -- sudo mv ./lxc /var/snap/lxd/common/lxc.debug
    lxc exec "${machine}" -- sudo mount --bind ./lxd-agent /snap/lxd/current/bin/lxd-agent
    lxc exec "${machine}" -- sudo systemctl reload snap.lxd.daemon
    lxc exec "${machine}" -- sudo snap set lxd daemon.debug=true
    lxc exec "${machine}" -- sudo systemctl reload snap.lxd.daemon
}

sideload_lxd micro1

echo "Nodes ready for microcloud initialization"

