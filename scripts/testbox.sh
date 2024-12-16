lxc launch ubuntu:n $1 --vm -c limits.cpu=2 -c limits.memory=2GiB -d root,size=50GiB
 
sleep 20
lxc file push ~/go/bin/lxd ~/go/bin/lxc ~/go/bin/lxd-agent $1/root/

lxc exec $1 -- sudo snap remove --purge lxd
lxc exec $1 -- sudo snap remove --purge lxd-installer
lxc exec $1 -- sudo snap install lxd --channel=latest/edge

lxc exec $1 -- sudo mv ./lxd /var/snap/lxd/common/lxd.debug
lxc exec $1 -- sudo mv ./lxc /var/snap/lxd/common/lxc.debug
lxc exec $1 -- sudo mount --bind ./lxd-agent /snap/lxd/current/bin/lxd-agent
lxc exec $1 -- sudo systemctl reload snap.lxd.daemon
lxc exec $1 -- sudo snap set lxd daemon.debug=true
lxc exec $1 -- sudo systemctl reload snap.lxd.daemon

# logs in /var/snap/lxd/common/lxd/logs/lxd.log
