#!/bin/bash

# Create disks
lxc storage create disks btrfs size=100GiB
lxc storage set disks volume.size 10GiB

lxc storage volume create disks local1 --type block
lxc storage volume create disks local2 --type block
lxc storage volume create disks local3 --type block
# lxc storage volume create disks local4 --type block

lxc storage volume create disks remote1 --type block size=10GiB
lxc storage volume create disks remote2 --type block size=10GiB
lxc storage volume create disks remote3 --type block size=10GiB
# lxc storage volume create disks remote4 --type block size=10GiB

# Init nodes
lxc init ubuntu:24.04 micro1 --vm --config limits.cpu=2 --config limits.memory=2GiB
lxc init ubuntu:24.04 micro2 --vm --config limits.cpu=2 --config limits.memory=2GiB
lxc init ubuntu:24.04 micro3 --vm --config limits.cpu=2 --config limits.memory=2GiB
# lxc init ubuntu:24.04 micro4 --vm --config limits.cpu=1 --config limits.memory=1GiB

# Attach disks
lxc storage volume attach disks local1 micro1
lxc storage volume attach disks local2 micro2
lxc storage volume attach disks local3 micro3
# lxc storage volume attach disks local4 micro4
lxc storage volume attach disks remote1 micro1
lxc storage volume attach disks remote2 micro2
lxc storage volume attach disks remote3 micro3
# lxc storage volume attach disks remote4 micro4

# Create uplink network
lxc network create microbr0

# Attach networks
lxc config device add micro1 eth1 nic network=microbr0 name=eth1
lxc config device add micro2 eth1 nic network=microbr0 name=eth1
lxc config device add micro3 eth1 nic network=microbr0 name=eth1
# lxc config device add micro4 eth1 nic network=microbr0 name=eth1

# Start nodes
lxc start micro1
lxc start micro2
lxc start micro3
# lxc start micro4

sleep 30

# Configure network
cat << EOF > 99-microcloud.yaml
# MicroCloud requires a network interface that doesn't have an IP address
network:
    version: 2
    ethernets:
        enp6s0:
            accept-ra: false
            dhcp4: false
            link-local: []
EOF

lxc file push 99-microcloud.yaml micro1/etc/netplan/
lxc file push 99-microcloud.yaml micro2/etc/netplan/
lxc file push 99-microcloud.yaml micro3/etc/netplan/
# lxc file push 99-microcloud.yaml micro4/etc/netplan/

lxc exec micro1 -- sh -c "chmod 0600 /etc/netplan/99-microcloud.yaml"
lxc exec micro2 -- sh -c "chmod 0600 /etc/netplan/99-microcloud.yaml"
lxc exec micro3 -- sh -c "chmod 0600 /etc/netplan/99-microcloud.yaml"
# lxc exec micro4 -- sh -c "chmod 0600 /etc/netplan/99-microcloud.yaml"

lxc exec micro1 -- sh -c "netplan apply"
lxc exec micro2 -- sh -c "netplan apply"
lxc exec micro3 -- sh -c "netplan apply"
# lxc exec micro4 -- sh -c "netplan apply"

sleep 15

lxc file push ~/go/bin/lxd micro1/root/
lxc file push ~/go/bin/lxd micro2/root/
lxc file push ~/go/bin/lxd micro3/root/
# lxc file push ~/go/bin/lxd micro4/root/

install_snaps() {
    local machine=$1

    lxc file pull renewing-monarch/root/go/bin/lxd ~/go/bin/lxd
    lxc file push ~/go/bin/lxd testbox/root/


    lxc exec "${machine}" -- sh -c 'snap install microceph --channel=squid/stable --cohort="+"'
    lxc exec "${machine}" -- sh -c 'snap install microcloud --channel=2/stable --cohort="+"'
    lxc exec "${machine}" -- sh -c 'snap install microovn --channel=24.03/stable --cohort="+"'
    lxc exec "${machine}" -- sh -c 'snap install lxd --channel=5.21/edge --cohort="+"'

    lxc exec "${machine}" -- sudo mv ./lxd /var/snap/lxd/common/lxd.debug
    lxc exec "${machine}" -- sudo systemctl reload snap.lxd.daemon
    lxc exec "${machine}" -- sudo snap set lxd daemon.debug=true
    lxc exec "${machine}" -- sudo systemctl start snap.lxd.daemon
    lxc exec "${machine}" -- sudo systemctl status snap.lxd.daemon
}

# Run the installations in parallel for each machine
install_snaps micro1 &
install_snaps micro2 &
install_snaps micro3 &
# install_snaps micro4 &

wait

echo "Nodes ready for microcloud initialization"

