#!/bin/bash

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

scp -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' /home/kadinsayani/utils/dpuSetup.sh ubuntu@10.241.0.33:/home/ubuntu/
scp -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' /home/kadinsayani/bf-bundle-2.9.1-30_24.11_ubuntu-22.04_prod.bfb ubuntu@10.241.0.33:/home/ubuntu/
ssh -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' ubuntu@10.241.0.33 "bash /home/ubuntu/dpuSetup.sh"