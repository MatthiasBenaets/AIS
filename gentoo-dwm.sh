#Finalizing
useradd -m -G users,wheel,audio,video,cdrom,usb -s /bin/bash matthias
(
My_hard_password
) | passwd matthias

emerge app-admin/sudo
sed '82d' /etc/sudoers
sed -i '82i%wheel ALL=(ALL) ALL'

rm /stage3-*.tar.xz

#Installing Display Server | Window Manager | Terminal
env-update
source /etc/profile

emerge -av x11-wm/dwm x11-terms/st x11-misc/dmenu x11-apps/setxkbmap x11-apps/xrandr
rc-update add elogind boot

touch /home/matthias/.xinitrc
echo "#!/bin/sh" >> /home/matthias/.xinitrc
echo "setxkbmap be" >> /home/matthias/.xinitrc
echo "exec dwm">> /home/matthias/.xinitrc
touch /etc/profile
echo "startx" >> /etc/profile

sudo reboot
