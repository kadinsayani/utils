# logs in /var/snap/lxd/common/lxd/logs/lxd.log

cd /home/kadinsayani/canonical/lxd; make; cd /home/kadinsayani
ssh $1 sudo snap remove --purge lxd
ssh $1 sudo snap remove --purge lxd-installer
ssh $1 sudo snap install lxd --channel=latest/edge

ssh $1 sudo mkdir -p /home/ubuntu/import/lxd && sudo mkdir -p /home/ubuntu/import/lxc && sudo mkdir -p /home/ubuntu/import/lxd-agent
scp -r /home/kadinsayani/go/bin/lxd $1:/home/ubuntu/import/lxd
scp -r /home/kadinsayani/go/bin/lxc $1:/home/ubuntu/import/lxc
scp /home/kadinsayani/go/bin/lxd-agent $1:/home/ubuntu/import/lxd-agent
ssh $1 sudo mv /home/ubuntu/import/lxd /var/snap/lxd/common/lxd.debug
ssh $1 sudo mv /home/ubuntu/import/lxc /var/snap/lxd/common/lxc.debug
ssh $1 sudo mount --bind /home/ubuntu/import/lxd-agent /snap/lxd/current/bin/lxd-agent
ssh $1 sudo systemctl reload snap.lxd.daemon
ssh $1 sudo snap set lxd daemon.debug=true
ssh $1 sudo systemctl reload snap.lxd.daemon
