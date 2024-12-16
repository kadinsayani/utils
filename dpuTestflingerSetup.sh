#!/bin/sh
set -eux

testflinger_yaml_job() {
  cat << EOF
job_queue: amontons
provision_data:
  distro: jammy
test_data:
  test_cmds: |
    set -eux
    export SSH_OPTS="-q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=30 -o ServerAliveCountMax=3"
    SCP="scp \$SSH_OPTS"
    SSH="ssh -n \$SSH_OPTS"
    wait_machine() {
      echo "==> Waiting for SSH to respond" >&2
      for i in \$(seq 600); do
        nc -w1 -z "\${DEVICE_IP}" 22 && break
        sleep 1
      done

      # Work around regression in cloud-init delaying SSH access
      # https://bugs.launchpad.net/ubuntu/+source/cloud-init/+bug/2039441
      for _ in \$(seq 30); do
        \$SSH -o ConnectTimeout=1 "ubuntu@\${DEVICE_IP}" true && break
        sleep 1
      done
    }
    # Uninstall previous DOCA
    for f in \$( dpkg --list | grep doca | awk '{print \$2}' ); do echo \$f ; apt remove --purge \$f -y ; done
    sudo apt-get autoremove
    # Install RShim
    wget https://www.mellanox.com/downloads/DOCA/DOCA_v2.9.1/host/doca-host_2.9.1-018000-24.10-ubuntu2204_amd64.deb
    sudo dpkg -i doca-host_2.9.1-018000-24.10-ubuntu2204_amd64.deb
    sudo apt-get update
    sudo apt-get -y install doca-all
    # Verify RShim is running on host
    sudo systemctl status rshim
    sudo systemctl restart rshim
    sudo cat /dev/rshim0/misc | grep DEV_NAME
    # Get DPU device-id
    sudo mst start
    sudo mst status -v
    # Install the Ubuntu BFB image
    sudo apt-get -y install pv
    TARGET_FILE="/home/ubuntu/bf-bundle-2.9.1-30_24.11_ubuntu-22.04_prod.bfb"
    echo "Waiting for file \${TARGET_FILE} to be SCP'd to the machine."
    while true; do
      if \$SSH "ubuntu@\${DEVICE_IP}" test -f "\${TARGET_FILE}"; then
        echo "File \${TARGET_FILE} exists! Continuing..."
        break
      else
        echo "File \${TARGET_FILE} not found. Waiting..."
        sleep 10
      fi
    done
    bfb-install --bfb bf-bundle-2.9.1-30_24.11_ubuntu-22.04_prod.bfb --rshim rshim0
    # Verify installation
    sudo cat /dev/rshim0/misc
    sudo cat /etc/mlnx-release
    # Upgrade the DPU firmware - done manually
EOF
}

setup_testflinger() {
  if ! wget --method HEAD -qO /dev/null https://testflinger.canonical.com/agents; then
    echo "Failed to connect to testflinger.canonical.com, make sure you are connected to the VPN" >&2
    exit 1
  fi
}

setup_testflinger
testflinger_yaml_job "$*" | testflinger submit --poll -