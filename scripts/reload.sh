lxc file push ~/go/bin/lxd c1/root/lxd
lxc file push ~/go/bin/lxd c2/root/lxd
lxc file push ~/go/bin/lxc c1/root/lxc
lxc file push ~/go/bin/lxc c2/root/lxc
lxc file push ~/go/bin/lxd-agent c1/root/lxd-agent
lxc file push ~/go/bin/lxd-agent c2/root/lxd-agent

lxc file push ~/utils/scripts/reload-instance-lxd.sh c1/root/sl.sh
lxc file push ~/utils/scripts/reload-instance-lxd.sh c2/root/sl.sh
