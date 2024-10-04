#!/bin/bash

lxc launch ubuntu:n v1 --vm
sleep 8000
lxc exec v1 lsblk | grep 10G
lxc config device override v1 root size=20GiB
lxc exec v1 lsblk | grep 20G
