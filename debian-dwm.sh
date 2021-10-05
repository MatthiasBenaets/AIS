#!/bin/bash

cd /home/matthias/
apt-get update -y
apt-get upgrade -y
apt-get install sudo xorg make git -y
echo 'matthias ALL=(ALL:ALL) ALL' >> /etc/sudoers

echo 'auto wlo1' >> /etc/network/interfaces
echo 'allow-hotplug wlo1' >> /etc/network/interfaces
echo 'iface wlo1 inet dhcp' >> /etc/network/interfaces
echo 'wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf' >> /etc/network/interfaces
echo 'iface default inet dhcp' >> /etc/network/interfaces

mkdir /etc/wpa_supplicant
touch /etc/wpa_supplicant/wpa_supplicant.conf
echo "Enter network ssid:"
read netssid
echo "Enter network password:"
read netpass
touch /etc/wpa_supplicant/wpa_supplicant.conf
echo 'network={' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'ssid='$netssid >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'psk='$netpass >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'proto=RSN' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'key_mgmt=WPA-PSK' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'pairwise=CCMP' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'auth_alg=OPEN' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo '}' >> /etc/wpa_supplicant/wpa_supplicant.conf

apt-get install gcc libx11-dev libxft-dev libxinerama-dev fonts-font-awesome -y

git clone https://www.github.com/MatthiasBenaets/dwm .dwm
git clone https://www.github.com/MatthiasBenaets/st .st
git clone https://git.suckless.org/dmenu .dmenu

cd /home/matthias/.dwm
make clean install
cd /home/matthias/.st
make clean install
cd /home/matthias/.dmenu
make clean install

echo 'startx' >> /etc/profile
touch /home/matthias/.xinitrc
echo 'exec dwm' >> /home/matthias/.xinitrc

apt-get install alsa-utils pulseaudio pavucontrol -y
pulseaudio --check
pulseaudio -D

apt-get install bluez blueman -y
sed -i '67iload-module module-switch-on-connect' /etc/pulse/default.pa
pulseaudio -k

touch /etc/X11/xorg.conf.d/70-synaptics.conf
echo 'Section "InputClass' >> /etc/X11/xorg.conf.d/70-synaptics.conf
echo 'Identifier "touchpad"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
echo 'Driver "synaptics"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
echo 'MatchIsTouchpad "on"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
echo 'Option "Tapping" "on"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
echo 'Option "NaturalScrolling" "on"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
echo 'EndSection' >> /etc/X11/xorg.conf.d/70-synaptics.conf

apt-get install feh compton -y
sed -i '1ifeh --bg-center /home/matthias/wall.jpg' /home/matthias/.xinitrc
sed -i '2icompton -f &' /home/matthias/.xinitrc

apt-get install ranger pip -y
ranger --copy-config=all
pip3 install ueberzug

sudo reboot
