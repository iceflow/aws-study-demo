#!/bin/bash

mkdir -p /data
/sbin/mkfs.ext4 /dev/xvdb

UUID=`blkid /dev/xvdb | cut -d\" -f2`
echo "UUID=$UUID /data                    ext4     defaults        0 0"  >> /etc/fstab

/bin/mount -a

exit 0
