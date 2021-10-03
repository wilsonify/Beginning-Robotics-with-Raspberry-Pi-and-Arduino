# clone kernel
git clone https://github.com/dhruvvyas90/qemu-rpi-kernel.git

# Run ARM/MIPS Debian on QEMU
# arm, debug, emulation, mips, qemu, qemu-system
#
# Introduction
# IoT engineers would like to emulate and debug architectures like ARM or MIPS.
#
# a good way to ease the pain of such debugging: running ARM/MIPS Debian on qemu-system.
# Here, I succeed in cutting down the installation time, compared to some other similar posts.
# ARM Debian is as an example, MIPS Debian is basically the same with .

# Background
# The most common way to install ARM Debian on qemu-system is by running netboot installer
# because its initrd and kernel can be easily obtained.
# In general, it’s feasible indeed, but due to the performance lost in qemu emulation,
# especially network adapters emulation, it’s almost impossible to finish the installation in a few hours.
# Thus, a better way should be running the offline installer but
# still I haven’t found any similar posts as the time of writing the post.
# After some exploration, I get the offline installer work and shorten the installation time from
# several hours to about half an hour.

# Preparation Environment
# install qemu
apt install qemu-system qemu-utils bridge-utils libguestfs-tools

# download the armhf Debian DVD.
wget -c "https://cdimage.debian.org/mirror/cdimage/archive/10.7.0/armhf/iso-dvd/debian-10.7.0-armhf-DVD-1.iso"

# Disk Image
# Create an empty disk image by qemu-img
qemu-img create -f qcow2 debian.qcow2 8G

# Extract initrd and kernel
# qemu-system requires initrd and kernel to emulate Linux.
# In fact, it’s grub’s work in a real boot process. Therefore, let’s check how it works.
mkdir mnt
sudo mount -o loop debian-10.6.0-armhf-DVD-1.iso ./mnt
cat mnt/boot/grub/grub.cfg

# And we can see the boot entry.
# menuentry 'Install' {
#    set background_color=black
#    linux    /install.ahf/vmlinuz  --- quiet
#    initrd   /install.ahf/initrd.gz
#}

# Extract initrd and kernel.
cp mnt/install.ahf/vmlinuz ./
cp mnt/install.ahf/initrd.gz ./

#Mount DVD
# You may already know that the Debian installer installs the whole system by just setting up /cdrom
# as the apt source and doing a big apt install.
# Thus, to install our ARM Debian,
# just mounting the DVD and starting the installer with initrd and kernel shall work as expected.
# However, I found that the -cdrom of the qemu-system didn’t work at all!
# I did lots of research but still didn’t know the exact reason.
# I guessed it was probably due to the driver problem.
# Therefore, I had to mount the DVD to /cdrom manually which would be shown in later chapters.

# Network Driver
# Another problem is that qemu-system doesn’t support PCI network card.
# According to some discussion, maybe the ARM Debian itself doesn’t have the corresponding support.
# In a word, to create a network adapter for ARM Debian,
# “virtio-blk-device” seems to be the only choice which can be specified by -netdev and -device.
# Note that -nic doesn’t work.

# Besides, for tap mode network cards, a bridge should be created.
brctl addbr br0
brctl addif br0 ens33 # ens33 is corresponding physical interface.
brctl addif br0 vmnic0
ip tuntap add dev vmnic0 mode tap
ip link set vmnic0 up
ip link set br0 up
ip addr add dev br0 192.168.4.158/24 # same subnet with ens33
systemd-resolve --interface=br0 --set-dns=192.168.4.1 # setup DNS
ip ro del default
ip ro add default via 192.168.4.1 dev br0
echo 1 > /proc/sys/net/ipv4/ip_forward

# Use -netdev tap,id=n0,ifname=vmnic0,script=no,downscript=no,br=br0 -device virtio-net-device,netdev=n0

# Install the System
# Finally, the full command line to run the offline installer.
# If tap network device is specified, the sudo is necessary.
sudo qemu-system-arm \
 -machine virt \
 -cpu cortex-a15 \
 -smp cpus=4,maxcpus=4 \
 -nographic \
 -kernel ./vmlinuz \
 -initrd ./initrd.gz \
 -m 1024 \
 -netdev user,id=n0 \
 -device virtio-net-device,netdev=n0 \
 -drive file=debian.qcow2,if=none,format=qcow2,id=hd0 \
 -device virtio-blk-device,drive=hd0 \
 -drive file=debian-10.6.0-armhf-DVD-1.iso,if=none,format=raw,id=hd1 \
 -device virtio-blk-device,drive=hd1

# Note that here debian-10.6.0-armhf-DVD-1.iso is mounted as an HDD, so the first error we get is cdrom missing.
# [cdrom]
# Select No and navigate to the main menu.
# [menu]
# Select Execute a Shell to enter busybox. In fact, I tried to send ALT+F2 in qemu-system console (CTRL+A C) but it didn’t work so I don’t have a better choice.
# dmesg would show disks mounted.
# [    9.713510] virtio_blk virtio0: [vda] 9117960 512-byte logical blocks (4.67 GB/4.35 GiB)
# [    9.741109]  vda: vda1 vda2
# [    9.755204] virtio_blk virtio1: [vdb] 16777216 512-byte logical blocks (8.59 GB/8.00 GiB)
# [    9.764864]  vdb: vdb1 vdb2 vdb3 < vdb5 >
#
# Obviously, /dev/vda is our DVD so just mount the installation partition to /cdrom.
modprobe isofs
mount /dev/vda1 /cdrom

# Then switch back to the main menu and select Detect and mount CD-ROM.
# The following process is quite straight-forward.
# However, for grub installing, it would prompt an error.
# [grub]
# It doesn’t matter at all since the grub work would be replaced by qemu-system.

# Boot
# Extract New initrd and kernel
# It’s time to boot our Debian now.
# The previous initrd and kernel can’t be used to boot the Debian
# so we have to extract new ones from the disk image.
# Here we use virt-ls and virt-copy-out. Note that root is required.
sudo virt-ls -l debian.qcow2 /boot

# Note the symbolic links of vmlinuz and initrd.
#drwxr-xr-x  3 0 0     1024 Nov 12 11:55 .
#drwxr-xr-x 18 0 0     4096 Nov 12 11:19 ..
#-rw-r--r--  1 0 0  3212152 Sep 17 21:42 System.map-4.19.0-11-armmp-lpae
#-rw-r--r--  1 0 0  3212349 Oct 18 08:43 System.map-4.19.0-12-armmp-lpae
#-rw-r--r--  1 0 0   210638 Sep 17 21:42 config-4.19.0-11-armmp-lpae
#-rw-r--r--  1 0 0   210638 Oct 18 08:43 config-4.19.0-12-armmp-lpae
#lrwxrwxrwx  1 0 0       31 Nov 12 11:51 initrd.img -> initrd.img-4.19.0-12-armmp-lpae
#-rw-r--r--  1 0 0 20587326 Nov 12 11:33 initrd.img-4.19.0-11-armmp-lpae
#-rw-r--r--  1 0 0 20590187 Nov 12 11:55 initrd.img-4.19.0-12-armmp-lpae
#lrwxrwxrwx  1 0 0       31 Nov 12 11:24 initrd.img.old -> initrd.img-4.19.0-11-armmp-lpae
#drwx------  2 0 0    12288 Nov 12 11:02 lost+found
#lrwxrwxrwx  1 0 0       28 Nov 12 11:51 vmlinuz -> vmlinuz-4.19.0-12-armmp-lpae
#-rw-r--r--  1 0 0  4403712 Sep 17 21:42 vmlinuz-4.19.0-11-armmp-lpae
#rw-r--r--  1 0 0  4403712 Oct 18 08:43 vmlinuz-4.19.0-12-armmp-lpae
#lrwxrwxrwx  1 0 0       28 Nov 12 11:24 vmlinuz.old -> vmlinuz-4.19.0-11-armmp-lpae

# Copy vmlinuz and initrd out.
sudo virt-copy-out -a debian.qcow2 /boot/initrd.img-4.19.0-12-armmp-lpae ./
sudo virt-copy-out -a debian.qcow2 /boot/vmlinuz-4.19.0-12-armmp-lpae ./

# Boot
# Finally, let’s boot our ARM Debian.

sudo qemu-system-arm \
-machine virt \
-cpu cortex-a15 \
-smp cpus=4,maxcpus=4 \
-nographic --append "root=/dev/vda2" \
-kernel ./vmlinuz-4.19.0-12-armmp-lpae \
-initrd ./initrd.img-4.19.0-12-armmp-lpae \
-m 1024 \
-netdev tap,ifname=vmnic1,id=n0,script=no,downscript=no \
-device virtio-net-device,netdev=n0 \
-drive file=debian.qcow2,if=none,format=qcow2,id=hd0 \
-device virtio-blk-device,drive=hd0

# [debian]
# Well done!

# Summary
# Compared to qemu-usermode which even doesn’t support multithread debugging,
# running ARM Debian on qemu-system has lots of benefits, like custom device,
# even debugging within the Debian.
# Besides, following the instructions in this post,
# it is expected to finish installation in half an hour,
# which is a big improvement compared to network install.

# Some hints:
# For those programs which are linked against musl or uclibc, Openwrt 19 uses musl while Openwrt 15 uses uclibc.
# ARM64 Debian can’t execute some ARM32 binary.
# Running Debian on some real device is also a good choice.
# For example, ARM raspberry PI, some MIPS routers, etc.
