#!/bin/bash
set -e
lxc launch ubuntu:n c1 -c limits.cpu=4 # container with cpu limit and no pinning
lxc launch ubuntu:n c2 -c limits.cpu=4 -c limits.cpu.pin_strategy=auto # container with cpu limit and pinning
lxc launch ubuntu:n c3 -c limits.cpu=4 -c limits.cpu.pin_strategy=none # container with cpu limit and no pinning
lxc launch ubuntu:n v2 --vm -c limits.cpu=4 # vm with cpu limit and no pinning
lxc launch ubuntu:n v3 --vm -c limits.cpu=1-2 -c limits.cpu.pin_strategy=auto # vm with cpu limit and pinning
lxc launch ubuntu:n v4 --vm -c limits.cpu=4 -c limits.cpu.pin_strategy=none # vm with cpu limit and no pinning
lxc stop -f c1 c2 c3 v2 v2 v3
lxc delete -f c1 c2 c3 v2 v2 v3

lxc launch ubuntu:n c1 -c limits.cpu=4-5 # container with cpu limit and no pinning
lxc launch ubuntu:n c2 -c limits.cpu=4-5 -c limits.cpu.pin_strategy=auto # container with cpu limit and pinning
! lxc launch ubuntu:n c3 -c limits.cpu=4-5 -c limits.cpu.pin_strategy=none || false # container with cpu limit and no pinning


