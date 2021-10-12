#Finalizing
echo "Choose a username"
read user
useradd -m -G users,wheel,audio,video,cdrom,usb -s /bin/bash $user
echo "Choose a password"
passwd $user

emerge app-admin/sudo dev-vcs/git
sed '82d' /etc/sudoers
sed -i '82i%wheel ALL=(ALL) ALL' /etc/sudoers

rm -rf /stage3-*.tar.xz

cd /home/$user

#Installing Display Server | Window Manager | Terminal | File Viewer | Compositor
emerge -v x11-base/xorg-server x11-base/xorg-drivers
env-update
source /etc/profile

emerge -v x11-wm/dwm x11-terms/st x11-misc/dmenu x11-apps/setxkbmap x11-apps/xrandr x11-misc/compton media-gfx/feh app-misc/ranger media-fonts/fontawesome
rc-update add elogind boot

#Downloading git repo
git clone https://www.github.com/MatthiasBenaets/dwm /home/$user/dwm
git clone https://www.github.com/MatthiasBenaets/st /home/$user/st
git clone https://www.github.com/MatthiasBenaets/dotfiles /home/$user/dotfiles

#Edit xinitrc
sleep 1s
cp /home/$user/dotfiles/.xinitrc /home/$user/ 
sed -i '2isetxkbmap be' /home/$user/.xinitrc
echo "Is this a Virtual Machine? [y/n]"
read vm
if [ "$vm" = "y" ]; then
	sed -i '2ixrandr --output Virtual-1 --mode 1280x960' /home/$user/.xinitrc 
fi
echo "startx" >> /etc/profile

#Creating folders and copying everything over
mkdir /etc/portage/patches/ /etc/portage/patches/x11-wm/ /etc/portage/patches/x11-terms/
cp -r /home/$user/dwm/patches /etc/portage/patches/x11-wm/dwm
cp -r /home/$user/st/patches /etc/portage/patches/x11-terms/st

sed -i '/#include "shiftview.c"/d' /home/$user/dwm/config.def.h
sed -i '/{ MODKEY,			XK_n,	   shiftview,	   {.i = +1 } },/d' /home/$user/dwm/config.def.h
sed -i '/{ MODKEY,			XK_b,	   shiftview,	   {.i = -1 } },/d' /home/$user/dwm/config.def.h

cp /home/$user/dwm/config.def.h /etc/portage/savedconfig/x11-wm/dwm-6.2
ln -s /etc/portage/savedconfig/x11-wm/dwm-6.2 /etc/portage/savedconfig/x11-wm/dwm-6.2.h
cp /home/$user/st/config.def.h /etc/portage/savedconfig/x11-terms/st-0.8.4
ln -s /etc/portage/savedconfig/x11-terms/st-0.8.4 /etc/portage/savedconfig/x11-terms/st-0.8.4.h
cp -r /home/$user/dwm/resc/sourcecodepro /usr/share/fonts/
fc-cache -fv
mkdir /home/$user/Pictures
cp /home/$user/dwm/resc/wall.jpg /home/$user/Pictures/
su -c "ranger --copy-config=all" -s /bin/sh $user
cp -f /home/$user/dotfiles/rc.conf /home/$user/.config/ranger/

#Optional for ranger preview:
#emerge dev-python/pip
#pip3 install ueberzug

#Rebuild and reboot
emerge dwm st
sudo reboot
