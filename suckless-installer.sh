#!/bin/bash

##########################################################################
#			SUCKLESS INSTALLATION SCRIPT			 #
#									 #
# This installer assumes you are already connected to the internet	 #
# Make sure sudo & wget is installed					 #
# - apt install sudo wget / pacman -S sudo wget / xbps-install sudo wget #
#   - If unable, update/upgrade package manager (see #BASE UPDATE)	 #
# - give user root priviliges: /etc/sudoers -> $USER ALL=(ALL:ALL) ALL   #
# Run script in home directory with sudo				 #
# - chmod +x suckless-installer.sh					 #
# - ./suckless-installer.sh						 #
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
AUR=null
BOOT=null
WIN=null
WIFI=null
SSID=null
PASS=null
VM=null
CARD=null
BLT=null
LAPTOP=null
#SCR=null
RES=null
LAYOUT=null

#CHOOSE DISTRIBUTION TO INSTALL SUCKLESS DESKTOP
DISTRO=$(cat /proc/sys/kernel/hostname)

if [[ "$DISTRO" =~ ^(debian|ubuntu)$ ]]; then
	DISTRO=1
elif [[ "$DISTRO" =~ ^(arch|manjaro)$ ]]; then
	DISTRO=2
elif [[ "$DISTRO" = "void" ]]; then
	DISTRO=3
else
	{ echo "Package manager or distro not supported. Edit script and proceed at your own risk"; exit; }
fi

USER=$(whoami)

#BASIC USER INPUT SETTINGS
##Dual boot
read -p $'Is this install part of a dual boot system using grub bootloader? [Y/n]' BOOT
VALID=false
until [[ "$VALID" =~ true ]]
do
	if [[ "$BOOT" =~ $yes ]]; then
		read -p $'with Microsoft Windows? [Y/n]' WIN
		VALID=true
	elif [[ "$VALID" =~ $no ]]; then
		VALID=true
	else
		echo "Non-Valid input"
		read -p 'Try again [Y/n]: ' BOOT
	fi
done
##AUR for arch with yay
if [ "$DISTRO" = 2 ]; then 
	read -p $'So you want to use Arch, èh? Also set up yay for download AUR-packages? [Y/n]' AUR
	VALID=false
	until [[ "$VALID" = true ]]
	do
		if [[ "$AUR" =~ $yes ]]; then
			VALID=true
		elif [[ "$AUR" =~ $no ]]; then
			VALID=true
		else
			echo "Non-Valid input"
			read -p 'Try again [Y/n]: ' AUR
		fi
	done	
fi
##Wifi
read -p $'Do you need NetworkManager for wifi? [Y/n]: ' WIFI
VALID=false
until [[ "$VALID" = true ]]
do	
	if [[ "$WIFI" =~ $yes ]]; then
		VALID=true
	elif [[ "$WIFI" =~ $no ]]; then
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
##Natural scrolling and TLP
VALID=false
read -p $'Is this a laptop? [Y/n]: ' LAPTOP
until [[ "$VALID" = true ]]
do
	if [[ "$LAPTOP" =~ $yes ]]; then
		VALID=true
	elif [[ "$LAPTOP" =~ $no ]]; then
		VALID=true
	else
		echo "Non-valid input"
		read -p 'Try again [Y/n]: ' LAPTOP
	fi	
done

#BASE UPDATE
if [ "$DISTRO" = 1 ]; then
	sudo apt update -y
	sudo apt upgrade -y
elif [ "$DISTRO" = 2 ]; then
	yes | sudo pacman -Syu
elif [ "$DISTRO" = 3 ]; then
	sudo xbps-install -Suy
fi

#INSTALL PACKAGES AND DEPENDENCIES
if [ "$DISTRO" = 1 ]; then
	sudo apt-get install xorg make gcc libx11-dev libxft-dev libxinerama-dev libx11-xcb-dev libxcb-res0-dev fonts-font-awesome sxhkd git alsa-utils pulseaudio pulsemixer feh compton ranger python3-pip vim -y
	pip3 install ueberzug
elif [ "$DISTRO" = 2 ]; then
	yes | sudo pacman -S make gcc libx11 libxft libxinerama libxcb xorg-setxkbmap xorg-xrandr xorg-xsetroot ttf-font-awesome sxhkd git alsa-utils pulseaudio pulsemixer feh xcompmgr ranger ueberzug vim
	if [ "$AUR" =~ $yes ]; then
		git clone https://aur.archlinux.org/yay-bin.git /home/$USER/.yay
		cd /home/$USER/.yay
		makepkg -si
		yay -Y --gendb
		yay -Syu --devel
		yay -Y --devel --save
	fi
elif [ "$DISTRO" = 3 ]; then
	sudo xbps-install xorg make gcc pkg-config libX11-devel libXft-devel libXinerama-devel setxkbmap xsetroot font-awesome sxhkd git alsa-utils pulseaudio pulsemixer feh compton ranger ueberzug vim -y
fi

#DUALBOOT
if [[ "$BOOT" =~ $yes ]]; then
	if [[ "$WIN" =~ $yes ]]; then
		if [ "$DISTRO" = 1 ]; then
			sudo apt install os-prober ntfs-3g -y
		elif [ "$DISTRO" = 2 ]; then
			yes | sudo pacman -S os-prober ntfs-3g
		elif [ "$DISTRO" = 3 ]; then
			sudo xbps-install os-prober ntfs-3g -y
		fi
		#Any issues with os-prober/ update-grub: add line "sudo grub-mkconfig -o /boot/grub/grub.cfg" accordingly. 
		sudo os-prober
	fi
	sudo update-grub
fi

#SETTING UP WIFI
if [[ "$WIFI" =~ $yes ]]; then
	if [ "$DISTRO" = 1 ]; then 
		sudo apt-get install network-manager -y
		sudo systemctl enable NetworkManager.service
	elif [ "$DISTRO" = 2 ]; then
		yes | sudo pacman -S networkmanager
		sudo systemctl enable NetworkManager.service
	elif [ "$DISTRO" = 2 ]; then
		sudo xbps-install NetworkManager -y
		sudo sv down dhcpcd
		sudo rm /var/service/dhcpcd
		sudo ln -s /etc/sv/NetworkManager /var/service/
	fi
fi

#CLONING SUCKLESS SOFTWARE
##Cloning Github
git clone https://www.github.com/MatthiasBenaets/dwm /home/$USER/.dwm
git clone https://www.github.com/MatthiasBenaets/dwmblocks /home/$USER/.dwmblocks
git clone https://www.github.com/MatthiasBenaets/st /home/$USER/.st
git clone https://www.github.com/MatthiasBenaets/dmenu /home/$USER/.dmenu
git clone https://www.github.com/MatthiasBenaets/old-dotfiles /home/$USER/.dotfiles
##Installing repositories
cd /home/$USER/.dwm
sudo make clean install
cd /home/$USER/.dwmblocks
sudo make clean install
cd /home/$USER/.st
sudo make clean install
cd /home/$USER/.dmenu
sudo make clean install

#STARTUP FILES AND DOTFILES
##Autostart Xserver on login
sudo bash -c 'echo "startx" >> /etc/profile'
##Wallpaper
mkdir /home/$USER/Pictures
cp /home/$USER/.dwm/resc/wall.jpg /home/$USER/Pictures
##Installing custom font
sudo cp -r /home/$USER/.dwm/resc/sourcecodepro /usr/share/fonts/opentype/
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
		sudo apt-get install bluez blueman pulseaudio-module-bluetooth -y
	elif [ "$DISTRO" = 2 ]; then
		yes | sudo pacman -S bluez bluez-utils blueman pulseaudio-bluetooth
	elif [ "$DISTRO" = 3 ]; then
		sudo xbps-install bluez blueman bluez-alsa -y
	fi
	sudo bash -c 'sed -i '67iload-module module-switch-on-connect' /etc/pulse/default.pa'
	sudo bash -c 'sed -i '250d' /etc/bluetooth/main.conf'
	sudo bash -c 'sed -i '250iAutoEnable=true' /etc/bluetooth/main.conf'

	if [ "$DISTRO" = 1 ] || [ "$DISTRO" = 2 ]; then
		sudo systemctl enable bluetooth.service
	elif [ "$DISTRO" = 3 ]; then
		sudo ln -s /etc/sv/bluetoothd /var/service/
		sudo ln -s /etc/sv/dbus /var/service/
	fi
fi

#LAPTOP
if [[ "$LAPTOP" =~ $yes ]]; then
	if [ "$DISTRO" = 1 ]; then
		sudo apt-get install libinput-bin tlp -y
		sudo systemctl enable tlp.service
	elif [ "$DISTRO" = 2 ]; then
		yes | sudo apt-get install libinput tlp
		sudo systemctl enable tlp.service
	elif [ "$DISTRO" = 3 ]; then
		sudo xbps-install libinput tlp -y
		sudo ln -s /etc/sv/tlp /var/service/
	fi

	sudo mkdir /etc/X11/xorg.conf.d
	sudo touch /etc/X11/xorg.conf.d/30-touchpad.conf
	sudo bash -c 'echo "Section \"InputClass\"" >> /etc/X11/xorg.conf.d/30-touchpad.conf'
	sudo bash -c 'echo "Identifier \"devname\"" >> /etc/X11/xorg.conf.d/30-touchpad.conf'
	sudo bash -c 'echo "Driver \"libinput\"" >> /etc/X11/xorg.conf.d/30-touchpad.conf'
	sudo bash -c 'echo "Option \"Tapping\" \"on\"" >> /etc/X11/xorg.conf.d/30-touchpad.conf'
	sudo bash -c 'echo "Option \"NaturalScrolling\" \"true\"" >> /etc/X11/xorg.conf.d/30-touchpad.conf'
	sudo bash -c 'echo "EndSection" >> /etc/X11/xorg.conf.d/30-touchpad.conf'
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
	#SCR=$(xrandr | sed -n 2p | cut -d" " -f1)
	RES=$(cvt 1920 1080 60 | sed -n -e 's/^.*"1920x1080_60.00"  //p')
	sed -i "1ixrandr --output Virtual1 --mode 1920x1080_60.00" /home/$USER/.xinitrc
	sed -i "1ixrandr --addmode Virtual1 1920x1080_60.00" /home/$USER/.xinitrc
	sed -i "1ixrandr --newmode \"1920x1080_60.00\" $RES" /home/$USER/.xinitrc

	sed -i '8 s/./#&/' /home/$USER/.dwmblocks/scripts/dwmvol
	sed -i '8s/^.//' /home/$USER/.dwmblocks/scripts/dwmvol
fi

#KEYBOARD LAYOUT
read -p $'What keyboard layout do you what to use? Give correct xkb_layout: ' LAYOUT
sed -i "5isetxkbmap $LAYOUT" /home/$USER/.xinitrc

#TIMEZONE FIX
sudo rm -rf /etc/localtime
sudo ln -s /usr/share/zoneinfo/Europe/Brussels /etc/localtime

#DONE
echo "Installation complete"
sleep 1
echo "Rebooting"
sleep 1
echo "3"
sleep 1
echo "2"
sleep 1
echo "1"
sleep 1
sudo reboot
