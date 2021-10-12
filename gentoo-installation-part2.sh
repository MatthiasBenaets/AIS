#Installing base system
mount /dev/sda1 /boot

emerge-webrsync
eselect profile set 1
emerge --verbose --update --deep --newuse @world

echo "Europe/Brussels" >> /etc/timezone
emerge --config sys-libs/timezone-data

sed -i '1ien_US ISO-8859-1' /etc/locale.gen
sed -i '2ien_US.UTF-8 UTF-8' /etc/locale.gen
locale-gen
eselect locale set 6
source /etc/profile

#Configuring the kernel
emerge sys-kernel/gentoo-sources
eselect kernel set 1
ls -l /usr/src/linux

emerge sys-kernel/genkernel
genkernel all
emerge sys-kernel/linux-firmware

#Configuring the system
echo "/dev/sda1    /boot   ext2     defaults,noatime   0 2" >> /etc/fstab
echo "/dev/sda2    /       ext4     noatime            0 1" >> /etc/fstab
sed -i '2d' /etc/conf.d/hostname
echo "hostname="gentoo"" >> /etc/conf.d/hostname

emerge --noreplace net-misc/netifrc

sed -i '3d' /etc/conf.d/keymaps
sed -i '3ikeymap="be"' /etc/conf.d/keymaps
sed -i '5d' /etc/conf.h/hwclock
sed -i '5iclock="UTC+2"'/etc/conf.d/hwclock
touch /etc/conf.d/net
echo 'iconfig_eth0="dhcp"' >> /etc/conf.d/net
cd /etc/init.d
ln -s net.lo net.eth0
rc-update add net.eth0 default

sed -i '17d' /etc/hosts
sed -i '17d' /etc/hosts
sed -i '17i127.0.0.1         gentoo   localhost' /etc/hosts
sed -i '18i::1               gentoo   localhost' /etc/hosts

echo "Give a root password:"
passwd

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

echo "-------------------------------------"
echo "         RUN THESE COMMANDS          "
echo "-------------------------------------"
echo "exit"
echo "cd"
echo "umount -l /mnt/gentoo/dev{/shm,/pts,}"
echo "umount -R /mnt/gentoo"
echo "reboot"
