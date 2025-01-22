#!/bin/bash
set -x

source /home/kadinsayani/canonical/lxd-ci/bin/tf-reserve
EXPECTED_OUTPUT="Now try logging into the machine"

echo "Running 'tf-reserve amontons jammy' and waiting for machine to be ready..."

while IFS= read -r line; do
    echo "$line"
    if echo "$line" | grep -q "$EXPECTED_OUTPUT"; then
        echo "Output '$EXPECTED_OUTPUT' detected. 'amontons' is ready. Proceeding..."
        break
    fi
done < <(tf-reserve amontons jammy)

echo "'amontons' is ready, continuing with the script..."

# Transfer BFB image to remote machine
scp -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' /home/kadinsayani/bf-bundle-2.9.1-30_24.11_ubuntu-22.04_prod.bfb ubuntu@10.241.0.33:/home/ubuntu/

# Remote machine details
REMOTE_USER="ubuntu"
REMOTE_HOST="10.241.0.33"

# Run DPU setup script on the remote machine
ssh -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' $REMOTE_USER@$REMOTE_HOST << 'EOF'
set -x

# Install LXD
sudo apt update
sudo apt install -y snapd
if command -v lxd &>/dev/null; then
    echo "LXD is already installed."
    sudo snap refresh --channel=latest/edge lxd
  else
    echo "LXD is not installed."
    sudo snap install lxd
fi
sudo lxd init --auto

# Uninstall previous DOCA
for f in $(dpkg --list | grep doca | awk '{print $2}'); do
    echo $f
    apt remove --purge $f -y
done
sudo apt-get autoremove

# Install RShim
wget https://www.mellanox.com/downloads/DOCA/DOCA_v2.9.1/host/doca-host_2.9.1-018000-24.10-ubuntu2204_amd64.deb
sudo dpkg -i doca-host_2.9.1-018000-24.10-ubuntu2204_amd64.deb
sudo apt-get update

# Install required packages
sudo apt-get -y install doca-all > /dev/null

# Verify RShim is running on host
sudo systemctl status rshim
sudo systemctl restart rshim
sudo systemctl status rshim
sudo cat /dev/rshim0/misc | grep DEV_NAME

# Get DPU device-id
sudo mst start
sudo mst status -v

# Install the Ubuntu BFB image
sudo apt-get -y install pv
bfb-install --bfb bf-bundle-2.9.1-30_24.11_ubuntu-22.04_prod.bfb --rshim rshim0

# Verify installation
sudo cat /dev/rshim0/misc

# Upgrade the DPU firmware
# sudo ip addr add 192.168.100.1/24 dev tmfifo_net0
# ssh ubuntu@192.168.100.2 # change ubuntu password
# ssh ubuntu@192.168.100.2
# sudo cat /etc/mlnx-release 
# sudo /opt/mellanox/mlnx-fw-updater/mlnx_fw_updater.pl --force-fw-update
# sudo reboot
EOF

echo "DPU setup script executed on 'amontons'."

# Wait until remote machine is ready
wait_machine() {
    echo "==> Waiting for SSH to respond" >&2
    # shellcheck disable=SC2034
    for i in $(seq 600); do
        nc -w1 -z $REMOTE_HOST 22 && break
        sleep 1
    done

    # Work around regression in cloud-init delaying SSH access
    # https://bugs.launchpad.net/ubuntu/+source/cloud-init/+bug/2039441
    for _ in $(seq 30); do
        ssh -o ConnectTimeout=1 $REMOTE_USER@$REMOTE_HOST true && break
        sleep 1
    done
}

# wait_machine

# Run OVN DPU setup script on the remote machine
# ssh -t -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' $REMOTE_USER@$REMOTE_HOST << 'EOF'
# set -x

# sudo ip addr add 192.168.100.1/24 dev tmfifo_net0
# ssh ubuntu@192.168.100.2
# ovs-vsctl show
# ovs-vsctl set open_vswitch . other_config:hw-offload=true
# lspci -vv
# # get serial number
# # ovs-vsctl set open_vswitch . external_ids:ovn-cms-options=card_serial_number=<DPU_SERIAL_NUMBER>
# EOF

# echo "OVN DPU setup script executed on 'amontons'."
