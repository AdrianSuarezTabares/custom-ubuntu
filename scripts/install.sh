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
apt install git wget curl 

# Instalar "flatpak", útil para instalar aplicaciones de escritorio
apt install flatpak
apt install gnome-software-plugin-flatpak gnome-software
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Instalar aplicaciones
# firefox
add-apt-repository ppa:mozillateam/ppa
apt update
apt install firefox

# google chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb

# edge 
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
rm microsoft.gpg
apt update && apt install microsoft-edge-stable

# Instalar thunderbird
flatpak install flathub org.mozilla.Thunderbird 
apt install gnome-shell-extension-manager


# instalar global protect
add-apt-repository ppa:yuezk/globalprotect-openconnect
apt-get update
apt-get install globalprotect-openconnect

# instalar trendmicro
# curl "https://files.trendmicro.com/products/deepsecurity/en/20.0/Manager-Linux-20.0.1017.x64.sh"
# aplica la configuración 
# sudo apt-get install dconf-cli
# cp gnome-config.conf /etc/skel/.config/dconf/user

# Cambia los logos por los de inatux
cp images/ubuntu-logo.png /usr/share/plymouth/ubuntu-logo.png
cp images/watermark.png /usr/share/plymouth/themes/spinner/watermark.png
cp images/bgrt-fallback.png /usr/share/plymouth/themes/spinner/bgrt-fallback.png

# Cambia el forndo de pantalla
cp images/inatux-background.png /usr/share/backgrounds/
cp images/inatux-logo.png /usr/share/plymouth/
# Aplica la configuración de escritorio
tar -xzvf dconf.tar.gz dconf/   
cp -r dconf /etc/
dconf update

# Copia un esqueleto para el home de nuevos usuarios 
tar -xzvf skel.tar.gz skel/
cp -r skel/ /etc/

# Copia un esqueleto para el home de nuevos usuarios 
tar -xzvf skel.tar.gz skel/
cp -r skel/ /etc/

# Modifica la configuración de gdm (pantalla de inicio)
cp greeter.dconf-defaults /etc/gdm3/
