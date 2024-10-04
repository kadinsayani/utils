cd /home/kadinsayani/canonical/lxd; make; cd /home/kadinsayani
sudo snap remove --purge lxd
sudo snap remove --purge lxd-installer
sudo snap install lxd --channel=latest/edge

sudo mv /home/kadinsayani/go/bin/lxd /var/snap/lxd/common/lxd.debug
sudo mv /home/kadinsayani/go/bin/lxc /var/snap/lxd/common/lxc.debug
sudo mount --bind /home/kadinsayani/go/bin/lxd-agent /snap/lxd/current/bin/lxd-agent
sudo systemctl reload snap.lxd.daemon
sudo snap set lxd daemon.debug=true
sudo systemctl reload snap.lxd.daemon
sudo lxd init --auto --storage-backend zfs
tmux new-session -d -s lxc-monitor 'lxc monitor --pretty'

# logs in /var/snap/lxd/common/lxd/logs/lxd.log
