#!/bin/bash

# Script for mounting EBS volumes onto aws instances
# We search for all unmounted disk devices, if there is exactly 1 we create an FS and mount it on /data
#
# Note that we don't partition the new device; with EBS it only makes sense to use the whole disk;
# if we need another mountpoint we can just attach another volume
DEVICES=( $(lsblk | grep disk | awk '{print $1}') )

TO_MOUNT=()
for i in "${DEVICES[@]}"
do
    echo ${i}
    OUT=$(lsblk -o MOUNTPOINT /dev/${i} | grep -v MOUNTPOINT | grep -v '^$')
    if [[ -z ${OUT} ]]; then
        TO_MOUNT+=($i)
    fi
done

TO_MOUNT_COUNT="${#TO_MOUNT[@]}"

if [ "${TO_MOUNT_COUNT}" == 0 ]; then
    echo "All disk devices are already mounted"
    exit 0
fi

if [ "${TO_MOUNT_COUNT}" != "1" ]; then
    echo "Cannot mount more than one device; got ${TO_MOUNT_COUNT}"
    exit 1
fi

for j in "${TO_MOUNT[@]}"
do
    FS_EXISTS=$(blkid /dev/${j} | grep TYPE)
    if [[ -z ${FS_EXISTS} ]]; then
        echo "Creating filesystem for device ${j}"
        mkfs -t ext4 /dev/${j}
    fi

    MOUNT_POINT="/data"
    echo "Creating mountpoint directory ${MOUNT_POINT}"
    mkdir -p ${MOUNT_POINT}

    echo "Mounting device ${j} on ${MOUNT_POINT}"
    mount /dev/${j} ${MOUNT_POINT}
done
