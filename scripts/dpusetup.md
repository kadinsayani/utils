# DPU deployment 

# https://docs.nvidia.com/networking/display/bluefielddpubspv420/deploying+bluefield+software+using+bfb+from+host

## Reserve Testflinger machine
See [How to reserve systems through Testflinger](https://docs.google.com/document/d/11Kot68mnBY9Wq9DXRzTVrKpx5cMkkhBC5RrM51eyybY/edit?tab=t.0#heading=h.61lqvfqp4kdv)
```
tf-reserve amontons jammy
```

## Uninstall previous DOCA on host (if exists)
```
for f in $( dpkg --list | grep doca | awk '{print $2}' ); do echo $f ; apt remove --purge $f -y ; done
sudo apt-get autoremove
```

## Install RShim on the host
```
wget https://www.mellanox.com/downloads/DOCA/DOCA_v2.9.1/host/doca-host_2.9.1-018000-24.10-ubuntu2204_amd64.deb
sudo dpkg -i doca-host_2.9.1-018000-24.10-ubuntu2204_amd64.deb
sudo apt-get update
sudo apt-get -y install doca-all
```

## Verify that RShim is running on the host
```
sudo systemctl status rshim
```

Expected output:
```
active (running)
...
Probing pcie-0000:<DPU’s PCIe Bus address on host>
create rshim pcie-0000:<DPU’s PCIe Bus address on host>
rshim<N> attached
```
Where <N> denotes RShim enumeration starting with 0 (then 1, 2, etc.) for every additional DPU installed on the server.

If the previous command displays inactive or another error, restart the service:
```
sudo systemctl restart rshim
```

Display the current setting:
```
sudo cat /dev/rshim<N>/misc | grep DEV_NAME
```

## Get DPU device-id
```
sudo mst start
sudo mst status -v
```

Example output:
```
MST modules:
------------
    MST PCI module is not loaded
    MST PCI configuration module loaded
PCI devices:
------------
DEVICE_TYPE             MST                           PCI       RDMA            NET
                  NUMA
BlueField2(rev:1)       /dev/mst/mtxxxxx_pciconf0.1   82:00.1   mlx5_1          net-enp1xxxxxxxxx
                  1

BlueField2(rev:1)       /dev/mst/mtxxxxx_pciconf0     82:00.0   mlx5_0          net-enp1xxxxxxxxx
                  1

```

# Install the Ubuntu BFB image
```
sudo apt-get -y install pv
```

[Download Ubuntu BFB image](https://developer.nvidia.com/doca-downloads?deployment_platform=BlueField&deployment_package=BF-Bundle&Distribution=Ubuntu&version=22.04&installer_type=BFB) on your local machine (you'll have to accept the NVIDIA DOCA EULA)

Send download to Testflinger machine:
```
scp -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' ./bf-bundle-2.9.1-30_24.11_ubuntu-22.04_prod.bfb ubuntu@x.x.x.x:/home/ubuntu
```

Install the image:
```
bfb-install --bfb bf-bundle-2.9.1-30_24.11_ubuntu-22.04_prod.bfb --rshim rshim0
```

# Verify installation completed successfully

```
sudo cat /dev/rshim0/misc
```

After installation of Ubuntu is complete, the following note appears in /dev/rshim0/misc on first boot:

```
...
INFO[MISC]: Linux up
INFO[MISC]: DPU is ready
```

```
cat /etc/mlnx-release
DOCA_v1.1_BlueField_OS_Ubuntu_22.04-<version>
```

# Upgrade the DPU firmware

```
sudo ip addr add 192.168.100.1/24 dev tmfifo_net0
ssh ubuntu@192.168.100.2
```

You will be prompted to change the default user password.

On the DPU:
```
sudo /opt/mellanox/mlnx-fw-updater/mlnx_fw_updater.pl --force-fw-update
```

Example output:
```
Device #1:
----------
 
  Device Type:      BlueField-2
  [...]
  Versions:         Current        Available
     FW             <Old_FW>       <New_FW>
```

Power cycle the host:
```
sudo reboot
```