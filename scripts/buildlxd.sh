#!/bin/bash

# Build on container
read -p "Which branch would you like to build?: " branch
cd lxd && git checkout $branch && make

# Prompt for testing
read -p "Do you want to test with a side-loaded LXD snap? (y/n): " response
if [[ "$response" =~ ^[Yy]$ ]]; then
	read -p "Which verison of Ubuntu would you like to test with?: " ubuntu
	read -p "Which channel would you like to test with?: " channel
	echo "Launching Ubuntu $ubuntu VM with side-loaded LXD ($channel) installed..." 
	name="lxd-test-vm-$ubuntu-$branch"
	lxc launch ubuntu:$2 $name --vm -c limits.cpu=8 -c limits.memory=8GiB --device root,size=5GiB
	sleep 60
	lxc file push ./lxd $name/root/lxd
	lxc file push ./lxc $name/root/lxc
	lxc file push ./lxd-agent $name/root/lxd-agent
	#lxc file push ./sl.sh $name/root/sl.sh
	lxc exec $name -- bash -c "
cat > /root/sl.sh << 'EOF'
#!/bin/bash
channel=\"\$1\"
sudo snap install lxd --channel=\$channel
sudo mv ~/lxd /var/snap/lxd/common/lxd.debug
sudo mv ~/lxc /var/snap/lxd/common/lxc.debug
sudo mount --bind ~/lxd-agent /snap/lxd/current/bin/lxd-agent
sudo systemctl reload snap.lxd.daemon
sudo snap set lxd daemon.debug=true
sudo systemctl reload snap.lxd.daemon
EOF
chmod +x /root/sl.sh
/root/sl.sh \"$channel\"
"
	#lxc exec $name -- /root/sl.sh "$channel"
	lxc exec $name -- su -

	# Clean up
	read -p "Do you want to destroy the VM? (y/n): " response
	if [[ "$response" =~ ^[Yy]$ ]]; then
		echo "Destroying VM..."
		lxc delete -f $name 
	fi
else
	echo "Skipping..."
fi

rm ./lxd && rm ./lxc && rm ./lxd-agent

