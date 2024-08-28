/home/ubuntu/canonical/scripts/sideload.sh
sudo lxd init
lxc launch images:alpine/edge c1 -c snapshots.expiry=1d
lxc snapshot c1
sudo LD_LIBRARY_PATH=/snap/lxd/current/lib/:/snap/lxd/current/lib/x86_64-linux-gnu/ nsenter --mount=/run/snapd/ns/lxd.mnt sed -n '/^volume_snapshots:$/,$ p' /var/snap/lxd/common/lxd/storage-pools/default/containers/c1/backup.yaml
lxc info c1 | sed -n '/^Snapshots:/,$ p'
sudo lxd sql global 'select * from instances_snapshots'; sudo lxd sql global 'select * from storage_volumes_snapshots'
