#!/bin/bash

# El script se ejecuta con permisos de root 
# Cabiar el idioma a español, lanza un gui
dpkg-reconfigure locales

# Desinstar snaps
apt autoremove --purge snapd
apt-mark hold snapd
apt install gnome-software --no-install-recommends

# actualizar el sistema 
apt update
apt upgrade
apt autoremove

# instalar aplicaciones de cli
apt install vim
apt install git 

# Instalar "flatpak", útil para instalar aplicaciones de escritorio
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
apt install gnome-software-plugin-flatpak gnome-software
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Instalar aplicaciones
flatpak install flathub firefox
flatpak install flathub chrome
flatpak install flathub edge
flatpak install flathub thunderbird
apt install gnome-shell-extension-manager


# instalar global protect
add-apt-repository ppa:yuezk/globalprotect-openconnect
apt-get update
apt-get install globalprotect-openconnect

# instalar trendmicro
# curl "https://files.trendmicro.com/products/deepsecurity/en/20.0/Manager-Linux-20.0.1017.x64.sh"
# aplica la configuración 
# sudo apt-get install dconf-cli
# dconf load / < gnome-config.txt

# Cambia los logos por los de inatux
cp images/ubuntu-logo.png /usr/share/plymouth/ubuntu-logo.png
cp images/watermark.png /usr/share/plymouth/themes/spinner/watermark.png
cp images/bgrt-fallback.png /usr/share/plymouth/themes/spinner/bgrt-fallback.png

# Cambia el fondo de pantalla
gsettings set org.gnome.desktop.background picture-uri "file:///~/Documentos/scripts/images/background.jpg"
