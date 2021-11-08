#!/bin/bash
#Before starting the script
#Apt install git and run as root
echo "What is your username? [case sensitive]"
read user

#Update and install essentials
#Add user to sudoers
apt-get update -y
apt-get upgrade -y
apt-get install sudo xorg make -y
sed -i '20i'$user' ALL=(ALL:ALL) ALL' /etc/sudoers

#Setup wifi
echo "Setup WiFi? [y/n]"
read wifi
if [ "$wifi" = "y" ]; then
echo 'auto wlo1' >> /etc/network/interfaces
echo 'allow-hotplug wlo1' >> /etc/network/interfaces
echo 'iface wlo1 inet dhcp' >> /etc/network/interfaces
echo 'wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf' >> /etc/network/interfaces
echo 'iface default inet dhcp' >> /etc/network/interfaces

mkdir /etc/wpa_supplicant
touch /etc/wpa_supplicant/wpa_supplicant.conf
echo "Enter Network SSID:"
read ssid
echo "Enter Network Password:"
read pass
touch /etc/wpa_supplicant/wpa_supplicant.conf
echo 'network={' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo "ssid="$ssid"" >> /etc/wpa_supplicant/wpa_supplicant.conf
echo "psk="$pass"" >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'proto=RSN' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'key_mgmt=WPA-PSK' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'pairwise=CCMP' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'auth_alg=OPEN' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo '}' >> /etc/wpa_supplicant/wpa_supplicant.conf
fi

#Install dependencies for Suckless
apt-get install gcc libx11-dev libxft-dev libxinerama-dev libx11-xcb-dev libxcb-res0-dev fonts-font-awesome sxhkd -y

#Cloning the github repos
git clone https://www.github.com/MatthiasBenaets/dwm /home/$user/.dwm
git clone https://www.github.com/MatthiasBenaets/st /home/$user/.st
git clone https://www.github.com/MatthiasBenaets/dmenu /home/$user/.dmenu
git clone https://www.github.com/MatthiasBenaets/dotfiles /home/$user/.dotfiles

#Install Suckless software
cd /home/$user/.dwm
make clean install
cd /home/$user/.st
make clean install
cd /home/$user/.dmenu
make clean install

#Startup files
echo 'startx' >> /etc/profile

#Install sound packages
apt-get install alsa-utils pulseaudio pulsemixer -y

#Install bluetooth packages w/ auto-switch
apt-get install bluez blueman -y
sed -i '67iload-module module-switch-on-connect' /etc/pulse/default.pa

#Setting up touchpad
touch /etc/X11/xorg.conf.d/70-synaptics.conf
echo 'Section "InputClass"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
echo 'Identifier "touchpad"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
echo 'Driver "synaptics"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
echo 'MatchIsTouchpad "on"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
echo 'Option "Tapping" "on"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
echo 'Option "NaturalScrolling" "on"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
echo 'EndSection' >> /etc/X11/xorg.conf.d/70-synaptics.conf

#Install image viewer and compositor
apt-get install feh compton -y
mkdir /home/$user/Pictures

#Install filemanager
apt-get install ranger pip -y
su -c "ranger --copy-config=all" -s /bin/sh $user
pip3 install ueberzug

#Customization
cp /home/$user/.dwm/resc/wall.jpg /home/$user/Pictures/
cp -R /home/$user/.dwm/resc/sourcecodepro /usr/share/fonts/opentype/
fc-cache -fv
cp -f /home/$user/.dotfiles/{.xinitrc,.bashrc} /home/$user/
cp -f /home/$user/.dotfiles/.config/ /home/$user/


#Xrandr for automated resolution in vm
echo "Is this a Virtual Machine? [y/n]"
read vm
if [ "$vm" = "y" ]; then
sed -i '1ixrandr --output Virtual1 --mode 1280x960' /home/$user/.xinitrc
fi

sudo reboot
