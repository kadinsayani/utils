#!/bin/sh

set -e

# do meson configuration (only needed once)

#meson setup \
#           --prefix=/ \
#           --datadir=/snap/lxd/current/ \
#           --localstatedir=/var/snap/lxd/common/var/ \
#           -Ddocs=false \
#           -Dtests=false \
#            build/

# compile LXCFS
meson compile -C build/

# get current LXD snap revision number
SNAP_REV=$(snap list lxd | awk '{print $3}' | tail -n 1)

# unmount overmounts may have created on the previous runs of this script (on the first run there is no overmounts, of course)
sudo umount -l /snap/lxd/${SNAP_REV}/bin/lxcfs || true

# overmount lxcfs executable inside snap with our new lxcfs executable
sudo mount --bind build/lxcfs /snap/lxd/${SNAP_REV}/bin/lxcfs

# do the same steps but this time for liblxcfs.so
sudo umount -l /snap/lxd/${SNAP_REV}/lib/liblxcfs.so || true
sudo mount --bind build/liblxcfs.so /snap/lxd/${SNAP_REV}/lib/liblxcfs.so

# kill LXCFS which is currently running in snap
sudo kill -9 $(sudo cat /var/snap/lxd/common/lxcfs.pid) || true
sudo killall -9 lxcfs || true

# be hard and just trigger LXD start/restart machinery
sleep 1
sudo systemctl start snap.lxd.daemon
sleep 1
sudo systemctl reload snap.lxd.daemon
sleep 3

# restart your testing container, so it can pick up a new LXCFS mounts
lxc restart my-container-i-use-to-test-lxcfs

# wait a bit and print a spawned LXCFS process PID so you know how to find it if needed
sleep 1
echo OK
sudo cat /var/snap/lxd/common/lxcfs.pid
