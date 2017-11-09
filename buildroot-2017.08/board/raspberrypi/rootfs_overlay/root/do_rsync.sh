#!/bin/sh

# usage: . /root/do_rsync.sh (only after . /root/do_chroot.sh)

# sync rootfs on sd card (/old_root/) with nfs rootfs (/) 
rsync -avh --exclude 'old_root' --exclude 'dev' --exclude 'proc' --exclude 'sys' --exclude 'tmp' --exclude 'var' --exclude 'run' / /old_root/ --delete
