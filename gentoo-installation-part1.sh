#!/bin/bash
#wget https://raw.githubusercontent.com/MatthiasBenaets/AIS/main/gentoo-installation-part1.sh
#chmod +x gentoo-installation-part1.sh
#./gentoo-installation-part1.sh

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

sed -i '5d' /mnt/gentoo/etc/portage/make.conf
sed -i '5iCOMMON_FLAGS="-O2 -pipe -march=native"' /mnt/gentoo/etc/portage/make.conf
sed -i '10iMAKEOPTS="-j6"' /mnt/gentoo/etc/portage/make.conf
sed -i '11iACCEPT_LICENSE="*"' /mnt/gentoo/etc/portage/make.conf
sed -i '12iINPUT_DEVICES="libinput synaptics"' /mnt/gentoo/etc/portage/make.conf
sed -i '13iUSE="-aqua -gnome -ios -ipod -kde -systemd -wayland -xfce alsa elogind pulseaudio savedconfig X"' /mnt/gentoo/etc/portage/make.conf

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

#Preparing part2
wget https://raw.githubusercontent.com/MatthiasBenaets/AIS/main/gentoo-installation-part2.sh
chmod +x /mnt/gentoo/gentoo-installation-part2.sh

echo "------------------------------------------------------"
echo "                RUN THESE COMMANDS                    "
echo "------------------------------------------------------"
echo "chroot /mnt/gentoo /bin/bash"
echo "source /etc/profile"
#wget https://raw.githubusercontent.com/MatthiasBenaets/AIS/main/gentoo-installation-part2.sh"
#chmod +x gentoo-installation-part2.sh"
echo "./gentoo-installation-part2.sh"
