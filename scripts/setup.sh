#!/bin/bash

# git clone
mkdir ~/canonical
cd ~/canonical
git clone https://github.com/kadinsayani/lxd && git clone https://github.com/kadinsayani/lxd-ci

# bashrc
cp ~/utils/.bashrc ~/.bashrc
source ~/.bashrc

# installs
# lxd
sudo apt update
sudo apt install acl attr autoconf automake dnsmasq-base git libacl1-dev libcap-dev liblxc1 liblxc-dev libsqlite3-dev libtool libudev-dev liblz4-dev libuv1-dev make pkg-config rsync squashfs-tools tar tcl xz-utils ebtables
command -v snap >/dev/null || sudo apt-get install snapd
sudo snap install --classic go
sudo apt install lvm2 thin-provisioning-tools
sudo apt install btrfs-progs
sudo apt install busybox-static curl gettext jq sqlite3 socat bind9-dnsutils
# utils
sudo snap install neovim --classic

# lxd setup
echo "root:1000000:1000000000" | sudo tee -a /etc/subuid /etc/subgid
getent group lxd >/dev/null || sudo groupadd --system lxd
getent group lxd | grep -qwF "$USER" || sudo usermod -aG lxd "$USER"
