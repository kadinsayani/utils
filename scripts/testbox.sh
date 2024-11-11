lxc stop -f testbox testc
lxc delete -f testbox testc
lxc launch ubuntu:n testbox --vm -c limits.cpu=4 -c limits.memory=4GiB -d root,size=100GiB
lxc launch ubuntu:n testc
 
cd ~/canonical/lxd && make
sleep 15
lxc file push ~/go/bin/lxd ~/go/bin/lxc ~/go/bin/lxd-agent testbox/root/

lxc exec testbox -- sudo snap remove --purge lxd
lxc exec testbox -- sudo snap remove --purge lxd-installer
lxc exec testbox -- sudo snap install lxd --channel=latest/edge

lxc exec testbox -- sudo mv ./lxd /var/snap/lxd/common/lxd.debug
lxc exec testbox -- sudo mv ./lxc /var/snap/lxd/common/lxc.debug
lxc exec testbox -- sudo mount --bind ./lxd-agent /snap/lxd/current/bin/lxd-agent
lxc exec testbox -- sudo systemctl reload snap.lxd.daemon
lxc exec testbox -- sudo snap set lxd daemon.debug=true
lxc exec testbox -- sudo systemctl reload snap.lxd.daemon

# logs in /var/snap/lxd/common/lxd/logs/lxd.log
