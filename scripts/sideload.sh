cd /home/ubuntu/canonical/lxd; make; cd /home/ubuntu
sudo snap remove --purge lxd
sudo snap remove --purge lxd-installer
sudo snap install lxd --channel=latest/edge

sudo mv /home/ubuntu/go/bin/lxd /var/snap/lxd/common/lxd.debug
sudo mv /home/ubuntu/go/bin/lxc /var/snap/lxd/common/lxc.debug
sudo mount --bind /home/ubuntu/go/bin/lxd-agent /snap/lxd/current/bin/lxd-agent
sudo systemctl reload snap.lxd.daemon
sudo snap set lxd daemon.debug=true
sudo systemctl reload snap.lxd.daemon

# logs in /var/snap/lxd/common/lxd/logs/lxd.log
