lxc stop -f testbox
lxc delete -f testbox
lxc launch ubuntu:n testbox --vm -c limits.cpu=2 -c limits.memory=2GiB -d root,size=25GiB
 
sleep 30

lxc file pull renewing-monarch/root/go/bin/lxd ~/go/bin/lxd
lxc file push ~/go/bin/lxd testbox/root/

lxc exec testbox -- sudo snap install lxd --channel=5.21/edge
lxc exec testbox -- sudo mv ./lxd /var/snap/lxd/common/lxd.debug
lxc exec testbox -- sudo systemctl reload snap.lxd.daemon
lxc exec testbox -- sudo snap set lxd daemon.debug=true
lxc exec testbox -- sudo systemctl start snap.lxd.daemon
lxc exec testbox -- sudo systemctl status snap.lxd.daemon
lxc exec testbox -- sudo snap install microceph --channel=squid/stable --cohort="+"
lxc exec testbox -- sudo snap install microovn --channel=24.03/stable --cohort="+"
lxc exec testbox -- sudo snap install microcloud --channel=2/stable --cohort="+"
lxc exec testbox -- microcloud init

# logs in /var/snap/lxd/common/lxd/logs/lxd.log
