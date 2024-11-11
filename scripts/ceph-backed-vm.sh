# installs
sudo snap install microceph
sudo snap refresh --hold microceph
snap install lxd --channel latest/edge

# setup
lxd init --auto
sudo microceph cluster bootstrap

# ceph setup
sudo microceph status
sudo microceph disk add loop,8G,4

# storage setup
lxc storage create pool1 ceph
lxc storage volume create pool1 vol1

# launch nested VM
lxc launch ubuntu:n v1 --storage pool1 --vm
