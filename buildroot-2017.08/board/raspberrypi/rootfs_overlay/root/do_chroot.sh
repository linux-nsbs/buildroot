#!/bin/sh

# usage: . /root/do_chroot.sh
#
# This script is intended to prepare system for update rootfs via nfs.
# - Set the nfs server ip address in server_ip variable, and path to the
#   root file system in rootfs variable.
# - Make sure that nfs server is up and running, and rootfs path is
#   exported from /etc/exports.
# - Change root file system to the nfs mounted, execute busybox init and
#   login as root user.
# - Source do_rsync.sh script to sync rootfs on sd card with nfs rootfs. 

server_ip="192.168.0.11"
rootfs="/home/bogic/work/buildroot/buildroot-2017.08/output/images/rootfs"

mount -t nfs -o nolock $server_ip:$rootfs /mnt
cd /mnt
pivot_root . old_root
exec chroot . sh -c 'exec /bin/busybox' <dev/console >dev/console 2>&1
