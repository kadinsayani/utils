#!/bin/sh

set -e

SNAP_REV=$(snap list lxd | awk '{print $3}' | tail -n 1)

meson compile -C build/

sudo umount -l /snap/lxd/${SNAP_REV}/lib/liblxcfs.so || true
sudo mount --bind /home/kadinsayani/canonical/lxcfs/build/liblxcfs.so /snap/lxd/${SNAP_REV}/lib/liblxcfs.so

sudo kill -s USR1 $(sudo cat /var/snap/lxd/common/lxcfs.pid) || true
