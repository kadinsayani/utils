lxc launch ubuntu:n --vm micro -c limits.cpu=2 -c limits.memory=4GiB
sleep 20
lxc exec micro -- sh -c 'snap install microceph --channel=squid/stable --cohort="+"'
lxc exec micro -- sh -c 'snap install microcloud --channel=2/stable --cohort="+"'
lxc exec micro -- sh -c 'snap install microovn --channel=24.03/stable --cohort="+"'
lxc exec micro -- sh -c 'snap install lxd --channel=5.21/stable --cohort="+"'
lxc file push ~/go/bin/lxd ~/go/bin/lxc ~/go/bin/lxd-agent micro/root/
lxc exec micro -- sudo mv ./lxd /var/snap/lxd/common/lxd.debug
lxc exec micro -- sudo mv ./lxc /var/snap/lxd/common/lxc.debug
lxc exec micro -- sudo mount --bind ./lxd-agent /snap/lxd/current/bin/lxd-agent
lxc exec micro -- sudo systemctl reload snap.lxd.daemon
lxc exec micro -- sudo snap set lxd daemon.debug=true
lxc exec micro -- sudo systemctl reload snap.lxd.daemon
