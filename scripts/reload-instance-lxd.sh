sudo mv ~/lxd /var/snap/lxd/common/lxd.debug
sudo mv ~/lxc /var/snap/lxd/common/lxc.debug
sudo mount --bind ~/lxd-agent /snap/lxd/current/bin/lxd-agent
sudo systemctl reload snap.lxd.daemon
sudo snap set lxd daemon.debug=true
sudo systemctl reload snap.lxd.daemon
