#!/bin/bash

# El script se ejecuta con permisos de root 
# Cabiar el idioma a español, lanza un gui
dpkg-reconfigure locales

# Desinstar snaps
# apt autoremove --purge snapd
# apt-mark hold snapd
# apt install gnome-software --no-install-recommends

# actualizar el sistema 
apt update
apt upgrade
apt autoremove

# instalar aplicaciones de cli
apt install vim git wget curl 

# Instalar "flatpak", útil para instalar aplicaciones de escritorio
apt install flatpak
apt install gnome-software-plugin-flatpak gnome-software
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Instalar aplicaciones
# firefox
# flatpak install flathub org.mozilla.firefox
install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla 
apt-get update && apt-get install firefox-l10n-es

# google chrome
# flatpak install flathub chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# edge 
# flatpak install flathub edge
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
rm microsoft.gpg
apt update && apt install microsoft-edge-stable

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

# Cambia el fondo de pantalla
gsettings set org.gnome.desktop.background picture-uri "file:///~/Documentos/scripts/images/background.jpg"

# Aplica la configuración de escritorio adecuada a los nuevos usuarios 
cp gnome-config.conf /etc/skel/.config/dconf/user