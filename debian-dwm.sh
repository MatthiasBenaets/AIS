#!/bin/bash
#apt install git and run as root

echo "What is your username? [case sensitive]"
read user

apt-get update -y
apt-get upgrade -y
apt-get install sudo xorg make git -y
sed -i '20i'$user' ALL=(ALL:ALL) ALL' /etc/sudoers

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
echo 'ssid='$ssid >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'psk='$pass >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'proto=RSN' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'key_mgmt=WPA-PSK' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'pairwise=CCMP' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo 'auth_alg=OPEN' >> /etc/wpa_supplicant/wpa_supplicant.conf
echo '}' >> /etc/wpa_supplicant/wpa_supplicant.conf
fi

apt-get install gcc libx11-dev libxft-dev libxinerama-dev fonts-font-awesome -y

git clone https://www.github.com/MatthiasBenaets/dwm /home/$user/.dwm
git clone https://www.github.com/MatthiasBenaets/st /home/$user/.st
git clone https://git.suckless.org/dmenu /home/$user/.dmenu

cd /home/$user/.dwm
make clean install
cd /home/$user/.st
make clean install
cd /home/$user/.dmenu
make clean install

echo 'startx' >> /etc/profile
touch /home/$user/.xinitrc
echo 'exec dwm' >> /home/$user/.xinitrc

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

echo "Is this a Virtual Machine? [y/n]"
read vm
apt-get install feh compton -y
mkdir /home/$user/Pictures
sed -i '1ifeh --bg-center /Pictures/wall.jpg' /home/$user/.xinitrc
sed -i '2icompton -f &' /home/$user/.xinitrc
if [ "$vm" = "y" ]; then
sed -i '1ixrandr --output Virtual1 --mode 1280x960' /home/$user/.xinitrc
fi

apt-get install ranger pip -y
ranger --copy-config=all
pip3 install ueberzug

sudo reboot
