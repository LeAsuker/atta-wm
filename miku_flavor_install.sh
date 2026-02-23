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
safe_download ruby

# has to overwrite global config
safe_download herbstluftwm
hlwm_link=https://raw.githubusercontent.com/ASTROfocs/Miku-Flavor/refs/heads/main/Configs/autostart
mkdir -p $HOME/.config/herbstluftwm
cd $HOME/.config/herbstluftwm
check_connection $hlwm_link
wget -O autostart $hlwm_link
chmod u+x autostart

hlwm_tpl_link=https://raw.githubusercontent.com/ASTROfocs/Miku-Flavor/refs/heads/main/Configs/autostart.template
check_connection $hlwm_tpl_link
wget -O autostart.template $hlwm_tpl_link

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

# Color theming engine
colors_link=https://raw.githubusercontent.com/ASTROfocs/Miku-Flavor/refs/heads/main/Configs/colors.yml
apply_link=https://raw.githubusercontent.com/ASTROfocs/Miku-Flavor/refs/heads/main/Configs/apply_colors.rb
check_connection $colors_link
wget -O colors.yml $colors_link
check_connection $apply_link
wget -O apply_colors.rb $apply_link

# Download templates for re-theming
for tpl in config.ini.template config.rasi.template alacritty.toml.template; do
    tpl_link=https://raw.githubusercontent.com/ASTROfocs/Miku-Flavor/refs/heads/main/Configs/$tpl
    check_connection $tpl_link
    wget -O $tpl $tpl_link
done

# Apply colors from YAML palette to all templates
ruby apply_colors.rb colors.yml $HOME/.config/mikuflavor
# Also apply to herbstluftwm autostart (separate directory)
ruby apply_colors.rb $HOME/.config/mikuflavor/colors.yml $HOME/.config/herbstluftwm

wp_link=https://raw.githubusercontent.com/LeAsuker/Miku-Flavor/6d876d9cfe7e2239dfcd6bb19eacca7ef2394d35/Wallpapers/WP_1.jpg
check_connection $wp_link
wget -O wp_1.jpg $wp_link

mkdir -p rofi-wifi-menu && cd rofi-wifi-menu


echo "Installation succesful!"
exit 0
