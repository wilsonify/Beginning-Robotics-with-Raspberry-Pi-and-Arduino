# Boundary Devices SABRE Lite (sabrelite)

# For QEMU’s Arm system emulation,
# you must specify which board model you want to use with the -M or --machine option; there is no default.
# Because Arm systems differ so much and in fundamental ways,
# typically operating system or firmware images intended to run on one machine will not run at all on any other.
# This is often surprising for new users who are used to the x86 world where every system looks like a standard PC.
# (Once the kernel has booted, most userspace software cares much less about the detail of the hardware.)
#
# If you already have a system image or a kernel that works on hardware and you want to boot with QEMU,
# check whether QEMU lists that machine in its -machine help output.
# If it is listed, then you can probably use that board model.
# If it is not listed, then unfortunately your image will almost certainly not boot on QEMU.
# (You might be able to extract the filesystem and use that with
# a different kernel which boots on a system that QEMU does emulate.)
#
# If you don’t care about reproducing the idiosyncrasies of a particular bit of hardware,
# such as small amount of RAM, no PCI or other hard disk, etc., and just want to run Linux,
# the best option is to use the virt board.
# This is a platform which doesn’t correspond to any real hardware and is designed for use in virtual machines.
# You’ll need to compile Linux with a suitable configuration for running on the virt board.
# virt supports PCI, virtio, recent CPUs and large amounts of RAM.
# It also supports 64-bit CPUs.

# Boundary Devices SABRE Lite i.MX6 Development Board is a low-cost development platform
# featuring the powerful Freescale / NXP Semiconductor’s i.MX 6 Quad Applications Processor.
# Supported devices
# The SABRE Lite machine supports the following devices:#
#        Up to 4 Cortex-A9 cores
#        Generic Interrupt Controller
#        1 Clock Controller Module
#        1 System Reset Controller
#        5 UARTs
#        2 EPIC timers
#        1 GPT timer
#        2 Watchdog timers
#        1 FEC Ethernet controller
#        3 I2C controllers
#        7 GPIO controllers
#        4 SDHC storage controllers
#        4 USB 2.0 host controllers
#        5 ECSPI controllers
#        1 SST 25VF016B flash

# Please note above list is a complete superset the QEMU SABRE Lite machine can support.
# For a normal use case, a device tree blob that represents a real world SABRE Lite board,
# only exposes a subset of devices to the guest software.

# Boot options
# The SABRE Lite machine can start using the standard -kernel functionality for loading a Linux kernel,
# U-Boot bootloader or ELF executable.

# Running Linux kernel
# Linux mainline v5.10 release is tested at the time of writing.
# To build a Linux mainline kernel that can be booted by the SABRE Lite machine,
# simply configure the kernel using the imx_v6_v7_defconfig configuration:
apt install flex bison gcc-arm* lzop
git clone https://github.com/torvalds/linux.git
cd linux
git checkout v5.10
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
make imx_v6_v7_defconfig
make
./tools/testing/selftests/rcutorture/bin/mkinitrd.sh

# create emtpy rootfs.img
# First, create a raw image of the required size.
# I'll assume 10G is enough. Using seek creates a sparse file, which saves space.
dd if=/dev/null of=rootfs.ext4 bs=1M seek=10240

#Next, create a filesystem on it.
#(Note that you need the -F option for mkfs.ext4 to operate on a file as opposed to a disk partition)
mkfs.ext4 -F rootfs.ext4

# Then, mount it.
mkdir -p mnt
mount -t ext4 -o loop rootfs.ext4 mnt

# Now you can copy your files to /mnt/example.
# Once this is done, unmount it and you can use example.img as a drive in a virtual machine.
# If you want you can convert it from a raw image to another format like qcow2e using qemu-img, but this isn't required.

# To boot the newly built Linux kernel in QEMU with the SABRE Lite machine, use:
qemu-system-arm \
-M sabrelite \
-smp 4 \
-m 1G \
-display none \
-serial null \
-serial stdio \
-kernel /home/thom/repos/linux/arch/arm/boot/zImage \
-dtb /home/thom/repos/linux/arch/arm/boot/dts/imx6q-sabrelite.dtb \
-initrd rootfs.ext4 \
-append "root=/dev/ram"

# Running U-Boot
# U-Boot mainline v2020.10 release is tested at the time of writing.
# To build a U-Boot mainline bootloader that can be booted by the SABRE Lite machine,
# use the mx6qsabrelite_defconfig with similar commands as described above for Linux:
git clone https://github.com/u-boot/u-boot.git
cd u-boot
git checkout v2020.10
export CROSS_COMPILE=arm-linux-gnueabihf-
make mx6qsabrelite_defconfig

# Note we need to adjust settings by:
make menuconfig

# then manually select the following configuration in U-Boot:
# Device Tree Control > Provider of DTB for DT Control > Embedded DTB
# To start U-Boot using the SABRE Lite machine,
# provide the u-boot binary to the -kernel argument, along with an SD card image with rootfs:

qemu-system-arm \
-M sabrelite \
-smp 4 \
-m 1G \
-display none \
-serial null \
-serial stdio \
-kernel u-boot

# The following example shows booting Linux kernel from dhcp, and uses the rootfs on an SD card.
# This requires some additional command line parameters for QEMU:

-nic user,tftp=/path/to/kernel/zImage \
-drive file=sdcard.img,id=rootfs \
-device sd-card,drive=rootfs

# The directory for the built-in TFTP server should also contain the device tree blob of the SABRE Lite board.
# The sample SD card image was populated with the root file system with one single partition.
# You may adjust the kernel “root=” boot parameter accordingly.
# After U-Boot boots, type the following commands in the U-Boot command shell to boot the Linux kernel:

=> setenv ethaddr 00:11:22:33:44:55
=> setenv bootfile zImage
=> dhcp
=> tftpboot 14000000 imx6q-sabrelite.dtb
=> setenv bootargs root=/dev/mmcblk3p1
=> bootz 12000000 - 14000000

qemu-system-arm \
-machine sabrelite \
-cpu cortex-a9 \
-smp cpus=4,maxcpus=4 \
-nographic \
-kernel /home/thom/repos/linux/arch/arm/boot/zImage \
-dtb /home/thom/repos/linux/arch/arm/boot/dts/imx6q-sabrelite.dtb \
-m 1024 \
-netdev user,id=n0 \
-device sd-card,drive=mydrive
-device virtio-net-device,netdev=n0 \
-drive file=debian.qcow2,if=none,format=qcow2,id=hd0 \
-device virtio-blk-device,drive=hd0 \
-drive file=debian-10.6.0-armhf-DVD-1.iso,if=none,format=raw,id=hd1 \
-device virtio-blk-device,drive=hd1


qemu-system-arm \
 -machine sabrelite \
 -cpu cortex-a9 \
 -smp cpus=4,maxcpus=4 \
 -nographic \
 -kernel fromUbuntu/vmlinuz \
 -initrd fromUbuntu/initrd \
 -dtb /home/thom/repos/linux/arch/arm/boot/dts/imx6q-sabrelite.dtb \
 -m 1024 \
 -device sd-card,drive=hd0 \
 -drive file=rootfs.qcow2,if=none,format=qcow2,id=hd0 \
 -device sd-card,drive=hd1 \
 -drive file=ubuntu-20.04.3-live-server-arm64.iso,if=none,format=raw,id=hd1



# Troubleshooting: "No 'virtio-bus' bus found for device 'virtio-net-device'"

# virtio is split into two layers:
# * transport (how the virtio device connects to the guest), # which could be PCI, or MMIO, or S390 device channels
# * backend (block, net, etc) and the two are connected via a 'virtio-bus' bus,
#   which is 1-1 (ie connects exactly one backend to one transport)

# virtio-net-device is a backend, and the error is telling you
# that there aren't any transports available to plug it into.

# You would need to also create a virtio-pci device
# (and use suitable options to both to ensure that the virtio-net-device is plugged into the virtio-pci device).

# Almost always you don't need to care about the split between
# backends and transports, because we provide convenience wrappers
# like virtio-net-pci, which are a PCI transport plus a backend
# already connected to each other and wrapped up in a handy
# single device package. It's possible to create and plug together
# a backend and a transport manually, but it's unnecessary complexity of the command line.

# Is there any particular reason you wanted to use virtio-net-device directly?
# The only use for it specifically is if you wanted
# to plug it directly into one of the legacy virtio-mmio
# transports provided on some ARM board models; but even there we recommend PCI virtio instead these days.

# sd card must be a power of 2
qemu-img convert -f raw -O qcow2 ubuntu-20.04.3-live-server-arm64.iso ubuntu-20.04.3-live-server-arm64.qcow2
qemu-img resize ubuntu-20.04.3-live-server-arm64.qcow2 2G

# Troubleshoot: Did not find UEFI binary for armv7l
# /usr/share/AAVMF/AAVMF32_CODE.fd