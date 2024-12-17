set -x

# Uninstall previous DOCA
for f in $( dpkg --list | grep doca | awk '{print $2}' ); do echo $f ; apt remove --purge $f -y ; done
sudo apt-get autoremove

# Install RShim
wget https://www.mellanox.com/downloads/DOCA/DOCA_v2.9.1/host/doca-host_2.9.1-018000-24.10-ubuntu2204_amd64.deb
sudo dpkg -i doca-host_2.9.1-018000-24.10-ubuntu2204_amd64.deb
sudo apt-get update

# sudo apt-get -y upgrade
sudo apt-get -y install doca-all > /dev/null

# Verify RShim is running on host
sudo systemctl status rshim
sudo systemctl restart rshim
sudo cat /dev/rshim0/misc | grep DEV_NAME

# Get DPU device-id
sudo mst start
sudo mst status -v

# Install the Ubuntu BFB image
sudo apt-get -y install pv
bfb-install --bfb bf-bundle-2.9.1-30_24.11_ubuntu-22.04_prod.bfb --rshim rshim0

# Verify installation
sudo cat /dev/rshim0/misc
sudo cat /etc/mlnx-release 

# Upgrade the DPU firmware
sudo ip addr add 192.168.100.1/24 dev tmfifo_net0
ssh ubuntu@192.168.100.2 # change ubuntu password
ssh ubuntu@192.168.100.2
sudo /opt/mellanox/mlnx-fw-updater/mlnx_fw_updater.pl --force-fw-update
sudo reboot