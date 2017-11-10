#!/bin/sh

# usage: . /root/sw_update.sh
#
# This script updates rootfs via nfs.
# - Make sure that nfs server is up and running, and rootfs path is
#   exported from /etc/exports.
# - Set proper values of server_ip and rootfs variables


server_ip="192.168.0.11"
rootfs="/home/bogic/work/buildroot/buildroot-2017.08/output/images/rootfs"

mount -t nfs -o nolock $server_ip:$rootfs /mnt
cd /mnt
pivot_root . old_root

rsync -avh --exclude 'old_root' --exclude-from '/root/exclude-list.txt' / /old_root/ --delete
