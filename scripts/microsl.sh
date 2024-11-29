sideload_lxd() {
    local machine=$1
    lxc exec "${machine}" -- sudo mv ./lxd /var/snap/lxd/common/lxd.debug
    lxc exec "${machine}" -- sudo mv ./lxc /var/snap/lxd/common/lxc.debug
    lxc exec "${machine}" -- sudo mount --bind ./lxd-agent /snap/lxd/current/bin/lxd-agent
    lxc exec "${machine}" -- sudo systemctl reload snap.lxd.daemon
    lxc exec "${machine}" -- sudo snap set lxd daemon.debug=true
    lxc exec "${machine}" -- sudo systemctl reload snap.lxd.daemon
}

sideload_lxd micro1 &
sideload_lxd micro2 &
sideload_lxd micro3 &

wait
