#!/bin/bash

##########################################################################
#			SUCKLESS INSTALLATION SCRIPT			 #
#									 #
# Make sure sudo & wget is installed					 #
# - apt install sudo wget / pacman -S sudo wget / xbps-install sudo wget #
#   - If unable, update/upgrade package manager (see #BASE UPDATE)	 #
# - give user root priviliges: /etc/sudoers -> $USER ALL=(ALL:ALL) ALL   #
# Run script in home directory with sudo				 #
# - chmod +x suckless-installer.sh					 #
# - sudo ./suckless-installer.sh					 #
# After installation, choose correct keyboard layout if needed		 #
# - vim /home/$USER/.xinitrc --> setxkbmap $LAYOUT			 #
##########################################################################

#VARIABLES
yes="^(y|yes|Y|Yes|YES|"")$"
no="^(n|no|N|No|NO)$"
prompt="PS1='\\[\\033[00;34m\\]\\u\\[\\033[00m\\]\\[\\033[00;37m\\]@\\[\\033[00m\\]\\[\\033[00;34m\\]\\h\\[\\033[00m\\]:\\[\\033[00;36m\\]\\w\\[\\033[00m\\]\\\$ '"
prompt2="PS1='\\\[\\\033[00;34m\\\]\\\u\\\[\\\033[00m\\\]\\\[\\\033[00;37m\\\]@\\\[\\\033[00m\\\]\\\[\\\033[00;34m\\\]\\\h\\\[\\\033[00m\\\]:\\\[\\\033[00;36m\\\]\\\w\\\[\\\033[00m\\\]\\\$ '"
VALID=false
DISTRO=null
USER=null
WIFI=null
SSID=null
PASS=null
VM=null
CARD=null
BLT=null
PAD=null

#CHOOSE DISTRIBUTION TO INSTALL SUCKLESS DESKTOP
read -rep $'Step 1\nWhat package manager does your distro use?\n[1]-Apt\t\t(Debian)\n[2]-Pacman\t( Arch )\n[3]-XBPS\t( Void )\nWM: ' DISTRO

until [[ "$VALID" = true ]]
do
	if [[ "$DISTRO" =~ ^(1|apt|Apt|APT)$ ]]; then 
		DISTRO=1
		VALID=true
	elif [[ "$DISTRO" =~ ^(2|pacman|Pacman|PACMAN)$ ]]; then
		DISTRO=2
		VALID=true
	elif [[ "$DISTRO" =~ ^(3|xbps|Xbps|XBPS)$ ]]; then
		DISTRO=3
		VALID=true
	else
		echo "Non-valid package manager"
		read -p "Try again: " DISTRO
	fi
done

#BASIC USER INPUT SETTINGS
##Username
read -p $'What is your username (case sensitive): ' USER
##Wifi
read -p $'Do you need wifi? No need if NetworkManager is installed [Y/n]: ' WIFI
VALID=false
until [[ "$VALID" = true ]]
do	
	if [[ "$WIFI" =~ $yes ]]; then
		read -p $'SSID: ' SSID
		read -p $'Password: ' PASS
		VALID=true
	elif [[ "$WIFI" =~ $no ]]; then
		echo "Excluding wifi setup"
		VALID=true
	else 
		echo "Non-valid input"
		read -p 'Try again [Y/n]: ' WIFI
	fi
done
##Bluetooth
VALID=false
read -p $'Setup Bluetooth? [Y/n]: ' BLT
until [[ "$VALID" = true ]]
do
	if [[ "$BLT" =~ $yes ]]; then
		VALID=true
	elif [[ "$BLT" =~ $no ]]; then
		VALID=true
	else
		echo "Non-valid input"
		read -p 'Try again [Y/n]: ' BLT
	fi	
done
##Trackpad natural scrolling
VALID=false
read -p $'Trackpad natural scrolling? [Y/n]: ' PAD
until [[ "$VALID" = true ]]
do
	if [[ "$PAD" =~ $yes ]]; then
		VALID=true
	elif [[ "$PAD" =~ $no ]]; then
		VALID=true
	else
		echo "Non-valid input"
		read -p 'Try again [Y/n]: ' PAD
	fi	
done

#BASE UPDATE
if [ "$DISTRO" = 1 ]; then
	apt update -y
	apt upgrade -y
elif [ "$DISTRO" = 2 ]; then
	yes | pacman -Syu
elif [ "$DISTRO" = 3 ]; then
	xbps-install -Suy
fi

#INSTALL PACKAGES AND DEPENDENCIES
if [ "$DISTRO" = 1 ]; then
	apt-get install xorg make gcc libx11-dev libxft-dev libxinerama-dev libx11-xcb-dev libxcb-res0-dev fonts-font-awesome sxhkd git alsa-utils pulseaudio pulsemixer feh compton ranger python3-pip vim -y
	pip3 install ueberzug
elif [ "$DISTRO" = 2 ]; then
	yes | pacman -S make gcc libx11 libxft libxinerama libxcb xorg-setxkbmap xorg-xrandr xorg-xsetroot ttf-font-awesome sxhkd git alsa-utils pulseaudio pulsemixer feh xcompmgr ranger ueberzug vim
elif [ "$DISTRO" = 3 ]; then
	xbps-install xorg make gcc pkg-config libX11-devel libXft-devel libXinerama-devel setxkbmap xsetroot font-awesome sxhkd git alsa-utils pulseaudio pulsemixer feh compton ranger ueberzug vim -y
fi

#SETTING UP WIFI
if [[ "$WIFI" =~ $yes ]]; then
	ip a
	read -p 'What is your wifi-card name (case sensitive): ' CARD
	echo "auto $CARD" >> /etc/network/interfaces
	mkdir /etc/network
	touch /etc/network/interfaces
	echo "allow-hotplug $CARD" >> /etc/network/interfaces
	echo "iface $CARD inet dhcp" >> /etc/network/interfaces
	echo 'wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf' >> /etc/network/interfaces
	echo 'iface default inet dhcp' >> /etc/network/interfaces

	mkdir /etc/wpa_supplicant
	touch /etc/wpa_supplicant/wpa_supplicant.conf
	echo 'network={' >> /etc/wpa_supplicant/wpa_supplicant.conf
	echo "ssid="$SSID"" >> /etc/wpa_supplicant/wpa_supplicant.conf
	echo "psk="$PASS"" >> /etc/wpa_supplicant/wpa_supplicant.conf
	echo 'proto=RSN' >> /etc/wpa_supplicant/wpa_supplicant.conf
	echo 'key_mgmt=WPA-PSK' >> /etc/wpa_supplicant/wpa_supplicant.conf
	echo 'pairwise=CCMP' >> /etc/wpa_supplicant/wpa_supplicant.conf
	echo 'auth_alg=OPEN' >> /etc/wpa_supplicant/wpa_supplicant.conf
	echo '}' >> /etc/wpa_supplicant/wpa_supplicant.conf
fi

#CLONING SUCKLESS SOFTWARE
##Cloning Github
git clone https://www.github.com/MatthiasBenaets/dwm /home/$USER/.dwm
git clone https://www.github.com/MatthiasBenaets/st /home/$USER/.st
git clone https://www.github.com/MatthiasBenaets/dotfiles /home/$USER/.dotfiles
git clone https://git.suckless.org/dmenu /home/$USER/.dmenu
##Installing repositories
cd /home/$USER/.dwm
make clean install
cd /home/$USER/.st
make clean install
cd /home/$USER/.dmenu
make clean install

#STARTUP FILES AND DOTFILES
##Autostart Xserver on login
echo 'startx' >> /etc/profile
##Wallpaper
mkdir /home/$USER/Pictures
cp /home/$USER/.dwm/resc/wall.jpg /home/$USER/Pictures
##Installing custom font
cp -r /home/$USER/.dwm/resc/sourcecodepro /usr/share/fonts/opentype/
fc-cache -fv
##Copying dotfiles
cp -f /home/$USER/.dotfiles/.xinitrc /home/$USER
cp -r /home/$USER/.dotfiles/.config /home/$USER
##Edit autostart show available updates
sed -i '9d' /home/$USER/.dwm/autostart.sh
sed -i '9d' /home/$USER/.dwm/autostart.sh
if [ "$DISTRO" = 1 ]; then
	sed -i '9iUPGRADE=$(apt list --upgradeable | wc -l)' /home/$USER/.dwm/autostart.sh
	sed -i '10iecho " $((UPGRADE-1))"' /home/$USER/.dwm/autostart.sh
elif [ "$DISTRO" = 2  ]; then
	sed -i '9iUPGRADE=$(pacman -Qu | wc -l)' /home/$USER/.dwm/autostart.sh
	sed -i '10iecho " $((UPGRADE))"' /home/$USER/.dwm/autostart.sh
elif [ "$DISTRO" = 3 ]; then
	sed -i '9iUPGRADE=$(xbps-install -Suvn | wc -l)' /home/$USER/.dwm/autostart.sh
	sed -i '10iecho " $((UPGRADE))"' /home/$USER/.dwm/autostart.sh
fi
##Edit .bashrc PS1
if [ "$DISTRO" = 1 ]; then
	sed -i '60d' /home/$USER/.bashrc
	sed -i "60i$prompt2" /home/$USER/.bashrc
elif [ "$DISTRO" = 2 ]; then
	sed -i '9d' /home/$USER/.bashrc
	echo "$prompt" >> /home/$USER/.bashrc
elif [ "$DISTRO" = 3 ]; then
	sed -i '7d' /home/$USER/.bashrc
	echo "$prompt" >> /home/$USER/.bashrc
fi
##Compositor Pacman
if [ "$DISTRO" = 2 ]; then
	sed -i '4d' /home/$USER/.xinitrc
	sed -i '4ixcompmgr &' /home/$USER/.xinitrc
fi

#BLUETOOTH
if [[ "$BLT" =~ $yes ]]; then
	if [ "$DISTRO" = 1 ]; then
		apt-get install bluez blueman -y
	elif [ "$DISTRO" = 2 ]; then
		yes | pacman -S bluez blueman
	elif [ "$DISTRO" = 3 ]; then
		xbps-install bluez blueman -y
	fi
	sed -i '67iload-module module-switch-on-connect' /etc/pulse/default.pa
fi
#TRACKPAD
if [[ "$PAD" =~ $yes ]]; then
	mkdir /etc/X11/xorg.conf.d
	touch /etc/X11/xorg.conf.d/70-synaptics.conf
	echo 'Section "InputClass"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
	echo 'Identifier "touchpad"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
	echo 'Driver "synaptics"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
	echo 'MatchIsTouchpad "on"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
	echo 'Option "Tapping" "on"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
	echo 'Option "NaturalScrolling" "on"' >> /etc/X11/xorg.conf.d/70-synaptics.conf
	echo 'EndSection' >> /etc/X11/xorg.conf.d/70-synaptics.conf
 
fi

#VIRTUAL MACHINE RESOLUTION
VALID=false
read -p $'Is this a virtual machine? [Y/n]: ' VM
until [[ "$VALID" = true ]]
do
	if [[ "$VM" =~ $yes ]]; then
		VALID=true
	elif [[ "$VM" =~ $no ]]; then
		VALID=true
	else
		echo "Non-valid input"
		read -p 'Try again [Y/n]: ' VM
	fi	
done

if [[ "$VM" =~ $yes ]]; then
	sed -i '1ixrandr --output Virtual1 --mode 1280x960' /home/$USER/.xinitrc
fi
#DONE
echo "Installation complete"
sleep 0.5
echo "Rebooting"
sleep 1
echo "3"
sleep 1
echo "2"
sleep 1
echo "1"
sleep 1
sudo reboot
