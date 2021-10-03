#!/bin/bash
# https://blahcat.github.io/2017/06/25/qemu-images-to-play-with/
# had to download vmlinuz-4.9.0-4-arm64, initrd.img-4.9.0-4-arm64, and disk.qcow2
# from https://mega.nz/folder/oMoVzQaJ#iS73iiQQ3t_6HuE-XpnyaA/file/oBBhFSyI

VM_USER=root
VM_PASSWD=root
VM_SSH_PORT=22355
VM_EXTRA_PORT=12334

NCPU=2
MEM=1G
KERNEL=vmlinuz-4.9.0-4-arm64
INITRD=initrd.img-4.9.0-4-arm64
HDD=disk.qcow2
OPT="root=/dev/sda2"

qemu-system-aarch64 \
-smp ${NCPU} \
-m ${MEM} \
-M virt \
-cpu cortex-a57  \
-initrd ${INITRD} \
-kernel ${KERNEL} \
-append "root=/dev/sda2 console=ttyAMA0" \
-global virtio-blk-device.scsi=off \
-device virtio-scsi-device,id=scsi \
-drive file=disk.qcow2,id=rootimg,cache=unsafe,if=none \
-device scsi-hd,drive=rootimg \
-device e1000,netdev=net0 \
-netdev user,hostfwd=tcp:127.0.0.1:${VM_SSH_PORT}-:22,hostfwd=tcp:127.0.0.1:${VM_EXTRA_PORT}-:${VM_EXTRA_PORT},id=net0 \
-net nic \
-nographic

exit 0



# root:root
# user: is created
# on stock image, pi:raspberry and is sudoer NOPASSWD. 

