# Launch vm with 4 cpus, 4GiB memory, and 100GiB disk
lxc launch ubuntu:n v1 -c limits.cpu=4 -c limits.memory=4GiB
lxc config device override v1 root size=100GiB
lxc stop v1
lxc start v1

sudo snap install microceph;sudo snap refresh --hold microceph;snap install lxd --channel latest/edge;lxd init --auto;sudo microceph cluster bootstrap;sudo microceph status
sudo microceph disk add loop,8G,4
lxc storage create pool1 ceph;lxc storage volume create pool1 vol1;lxc launch ubuntu:n v1 --storage pool1
lxc ls
lxc snapshot
lxc storage set pool1 ceph.rbd.du=true
lxc storage set pool1 ceph.rbd.du=false
lxc snapshot v1 snap1
lxc config show v1/snap1
lxc storage set pool1 ceph.rbd.du=true
lxc config show v1/snap1
