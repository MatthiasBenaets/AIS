#!/bin/bash
#wget https://www.github.com/MatthiasBenaets/AIS/archive/main.zip
#unzip & run

#Preparing the disks
(
echo o
echo n
echo p
echo 1
echo 
echo +256M
echo n
echo p
echo 2
echo
echo
echo a
echo 1
echo w
) | fdisk /dev/sda

mkfs.ext2 /dev/sda1
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt/gentoo

#Installing stage3
cd /mnt/gentoo
links gentoo.org/downloads
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

sed '5d' /mnt/gentoo/etc/portage/make.conf
sed -i '5iCOMMON_FLAGS="-O2 -pipe -march=native"' /mnt/gentoo/etc/portage/make.conf
sed -i '10iMAKEOPTS="-j6"' /mnt/gentoo/etc/portage/make.conf
sed -i '11iACCEPT_LICENSE="*"' /mnt/gentoo/etc/portage/make.conf
set -i '12iINPUT_DEVICES="libinput synaptics"'
sed -i '13iUSE="-aqua -gnome -ios -ipod -kde -systemd -wayland -xfce alsa pulseaudio X"' /mnt/gentoo/etc/portage/make.conf
#sed -i 'i13VIDEO_CARDS=" "'

#Installing base system
mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

chroot /mnt/gentoo /bin/bash
. /etc/profile
mount /dev/sda1 /boot

emerge-webrsync
eselect profile set 1
emerge --verbose --update --deep --newuse @world

echo "Europe/Brussels" >> /etc/timezone
emerge --config sys-libs/timezone-data

sed -i '1ien_US ISO-8859-1'
sed -i '2ien_US.UTF-8 UTF-8'
locale-gen
eselect locale set 6
. /etc/profile

#Configuring the kernel
emerge sys-kernel/gentoo-sources
eselect kernel set 1
ls -l /usr/src/linux

emerge sys-kernel/genkernel
genkernel all
emerge sys-kernel/linux-firmware

#Configuring the system
echo "/dev/sda1		/boot		ext2	defaults,noatime	0 2" >> /etc/fstab
echo "/dev/sda2		/		ext4	noatime			0 1" >> /etc/fstab
sed '2d' /etc/conf.d/hostname
echo "hostname="gentoo"" >> /etc/conf.d/hostname

emerge --noreplace net-misc/netifrc

sed '3d' /etc/conf.d/keymaps
sed -i '3ikeymap="be"' /etc/conf.d/keymaps
sed '5d' /etc/conf.h/hwclock
sed -i '5iclock="UTC+2"'/etc/conf.d/hwclock
touch /etc/conf.d/net
echo "config_eth0="dhcp"" >> /etc/conf.d/net
cd /etc/init.d
ln -s net.lo net.eth0
rc-update add net.eth0 default

sed '17d' /etc/hosts
sed '18d' /etc/hosts
sed -i '17i127.0.0.1 	gentoo	localhost'
sed -i '18i::1		gentoo	localhost'

(
My_hard_password
) | passwd

#Installing tools
emerge app-admin/sysklogd
rc-update add sysklogd default
emerge sys-fs/e2fsprogs
emerge net-misc/dhcpcd
##Optional wifi
#emerge net-wireless/iw net-wireless/wpa_supplicant

#Configuring the bootloader
emerge --verbose sys-boot/grub:2
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
exit
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot

#Finalizing
