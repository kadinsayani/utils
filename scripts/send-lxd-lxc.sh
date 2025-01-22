#!/bin/bash

# Build LXD
cd ~/canonical/lxd && make

# Copy binaries to the first machine
scp -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' /home/kadinsayani/go/bin/lxd ubuntu@10.241.0.33:/home/ubuntu/
scp -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' /home/kadinsayani/go/bin/lxc ubuntu@10.241.0.33:/home/ubuntu/
scp -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' /home/kadinsayani/go/bin/lxd-agent ubuntu@10.241.0.33:/home/ubuntu/
scp -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' /home/kadinsayani/utils/scripts/sl.sh ubuntu@10.241.0.33:/home/ubuntu/

# ssh -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' ubuntu@10.241.0.33 ./home/ubuntu/remote-sl.sh
# ssh -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' ubuntu@10.241.0.33 scp ./home/ubuntu/sl.sh ubuntu@192.168.100.2:/home/bin
