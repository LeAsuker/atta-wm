#!/bin/bash

check_connection() {
	if ! curl --head --silent $1 >/dev/null 2>&1; then
    	echo "[!] Could not reach github for $1 setup, exiting with 1."
		exit 1
	fi
}

install_fail() {
	echo "[!] Failed to install $1, ending script."
	exit 1	
}

safe_download() {
	apt -y install $1 || install_fail $1
}

apt update

safe_download wget 
safe_download feh

# has to overwrite global config
safe_download herbstluftwm
hlwm_link=https://raw.githubusercontent.com/ASTROfocs/Miku-Flavor/refs/heads/main/Configs/autostart
mkdir -p $HOME/.config/herbstluftwm
cd $HOME/.config/herbstluftwm
check_connection $hlwm_link
wget -O autostart $hlwm_link
chmod u+x autostart

# Universal config folder
mkdir -p $HOME/.config/mikuflavor
cd $HOME/.config/mikuflavor

safe_download rofi
rofi_link=https://raw.githubusercontent.com/ASTROfocs/Miku-Flavor/refs/heads/main/Configs/config.rasi
check_connection $rofi_link
wget -O config.rasi $rofi_link


safe_download polybar
polybar_link=https://raw.githubusercontent.com/ASTROfocs/Miku-Flavor/refs/heads/main/Configs/config.ini
check_connection $polybar_link
wget -O config.ini $polybar_link

safe_download picom
picom_link=https://raw.githubusercontent.com/ASTROfocs/Miku-Flavor/refs/heads/main/Configs/picom.conf
check_connection $picom_link
wget -O picom.conf $picom_link

safe_download alacritty
alacritty_link=https://raw.githubusercontent.com/ASTROfocs/Miku-Flavor/refs/heads/main/Configs/alacritty.toml
check_connection $alacritty_link
wget -O alacritty.toml $alacritty_link

wp_link=https://raw.githubusercontent.com/LeAsuker/Miku-Flavor/6d876d9cfe7e2239dfcd6bb19eacca7ef2394d35/Wallpapers/WP_1.jpg
check_connection $wp_link
wget -O wp_1.jpg $wp_link

echo "Installation succesful!"
exit 0
