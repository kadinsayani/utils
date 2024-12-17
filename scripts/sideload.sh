sudo snap remove --purge lxd
sudo snap remove --purge lxd-installer
sudo snap install lxd --channel=latest/edge

cd ~/canonical/lxd && make
sudo mv ~/go/bin/lxd /var/snap/lxd/common/lxd.debug
sudo mv ~/go/bin/lxc /var/snap/lxd/common/lxc.debug
sudo mount --bind ~/go/bin/lxd-agent /snap/lxd/current/bin/lxd-agent
sudo systemctl reload snap.lxd.daemon
sudo snap set lxd daemon.debug=true
sudo systemctl reload snap.lxd.daemon

# logs in /var/snap/lxd/common/lxd/logs/lxd.log
