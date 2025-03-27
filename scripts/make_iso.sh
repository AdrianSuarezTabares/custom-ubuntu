#!/bin/bash

builddir=~/Documentos/inatux-build
chrootdir=$builddir/chroot
osurl=http://archive.ubuntu.com/ubuntu/

# Personaliza la instalación
customize() {
  setupdir=/setup
  mkdir -p $setupdir
  git clone https://github.com/AdrianSuarezTabares/custom-ubuntu.git $setupdir 
  cd $setpdir/scripts
  # actualizar el sistema 
  apt update
  apt upgrade
  apt autoremove

  # chromium
  apt install chromium-browser
  # google chrome
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  dpkg -i google-chrome-stable_current_amd64.deb

  # edge 
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
  sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
  rm microsoft.gpg
  apt update && apt install microsoft-edge-stable

  # global protect
  add-apt-repository ppa:yuezk/globalprotect-openconnect
  apt-get update
  apt-get install globalprotect-openconnect

  # horizon
  wget https://download3.omnissa.com/software/CART25FQ4_LIN64_DebPkg_2412/Omnissa-Horizon-Client-2412-8.14.0-12437214089.x64.deb
  dpkg -i Omnissa-Horizon-Client-2412-8.14.0-12437214089.x64.deb
  rm Omnissa-Horizon-Client-2412-8.14.0-12437214089.x64.deb

  # el agente de Deep Security
  wget "https://files.trendmicro.com/products/deepsecurity/en/20.0/Agent-Ubuntu_24.04-20.0.2-4961.x86_64.zip" -O DP_Agent.zip
  unzip DP_Agent.zip -d DP_Agent
  dpkg -i DP_Agent/Agent-Core-Ubuntu_24.04-20.0.2-4961.x86_64.deb
  rm -fr DP_Agent.zip DP_Agent
  # systemctl start ds_agent

  ## Cambia el branding del sistema 
  # Cambia los logos por los de inatux
  cp -r inatux-theme /usr/share/plymouth/themes/
  update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/inatux-theme/inatux.plymouth 100
  update-alternatives --config default.plymouth
  cp images/inatux.svg /usr/share/icons/Yaru/scalable/actions/view-app-grid-ubuntu-symbolic.svg
  

  # Cambia el fondo de pantalla
  rm /usr/share/backgrounds/*
  cp images/Wallpaper.jpg /usr/share/backgrounds/
  cp images/ubuntu-logo.png /usr/share/plymouth/inatux-logo.png

  # Aplica la configuración de escritorio
  tar -xzvf dconf.tar.gz dconf/   
  cp -r dconf /etc/
  # Modifica la configuración de gdm (pantalla de inicio)
  cp greeter.dconf-defaults /etc/gdm3/
  dconf update

  ## Copia un esqueleto para el home de nuevos usuarios 
  mkdir -p /etc/skel/Escritorio
  # Atajos de las aplicaciones en el escritorio
  cp /usr/share/applications/chromium-browser.desktop /etc/skel/Escritorio/
  cp /usr/share/applications/horizon-client.desktop /etc/skel/Escritorio/
  cp /usr/share/applications/google-chrome.desktop /etc/skel/Escritorio/
  cp /usr/share/applications/gpgui.desktop /etc/skel/Escritorio/
  cp /usr/share/applications/microsoft-edge.desktop /etc/skel/Escritorio/


  ## Scripts
  cp update.sh /usr/local/bin/

  ## Fin
  # Borrar el directorio de setup
  cd /
  rm -fr $setupdir
}

## Preparación
# Instala los paquetes necesarios 
sudo apt update
sudo apt install -y debootstrap squashfs-tools genisoimage xorriso

mkdir -p $chrootdir

# Crear el sistema de archivos
sudo debootstrap \
  --arch=amd64 \
  --variant=minbase \
  noble \
  $chrootdir \
  $osurl

# Configurar puntos de montaje 
sudo mount --bind /dev $chrootdir/dev
sudo mount --bind /run $chrootdir/run
# Entra en el entoro live
sudo chroot $chrootdir

mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C

# Configura el nombre del host
echo "inatux-fs-live" > /etc/hostname

# Configura las fuentes 
cat <<EOF > /etc/apt/sources.list
deb http://us.archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse

deb http://us.archive.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse

deb http://us.archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse
EOF


# Instalar paquetes
apt-get update
apt-get install -y libterm-readline-gnu-perl systemd-sysv

dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id

dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

apt-get -y upgrade

# Paquetes necesarios para el live-system
apt-get install -y \
   sudo \
   ubuntu-standard \
   casper \
   discover \
   laptop-detect \
   os-prober \
   network-manager \
   net-tools \
   wireless-tools \
   wpagui \
   locales \
   grub-common \
   grub-gfxpayload-lists \
   grub-pc \
   grub-pc-bin \
   grub2-common \
   grub-efi-amd64-signed \
   shim-signed \
   mtools \
   binutils

apt-get install -y --no-install-recommends linux-generic

# probar sin ubuntu artwork
apt-get install -y \
   ubiquity \
   ubiquity-casper \
   ubiquity-frontend-gtk \
   ubiquity-slideshow-ubuntu \
   ubiquity-ubuntu-artwork

# probar sin esto wallpapers
apt-get install -y \
   plymouth-themes \
   ubuntu-gnome-desktop 

apt-get install -y \
   clamav-daemon \
   terminator \
   apt-transport-https \
   curl \
   vim \
   nano \
   git \
   wget \
   less

# Eliminar paquetes no necesarios
apt-get purge -y \
   transmission-gtk \
   transmission-common \
   gnome-mahjongg \
   gnome-mines \
   gnome-sudoku \
   aisleriot \
   hitori

apt-get autoremove -y

# Instalar applicaciones
customize

# Configurar idioma
dpkg-reconfigure locales

# Configurar redes
cat <<EOF > /etc/NetworkManager/NetworkManager.conf
[main]
rc-manager=none
plugins=ifupdown,keyfile
dns=systemd-resolved

[ifupdown]
managed=false
EOF

dpkg-reconfigure network-manager

#Configuración la imagen
mkdir -p /image/{casper,isolinux,install}
cp /boot/vmlinuz-**-**-generic /image/casper/vmlinuz
cp /boot/initrd.img-**-**-generic /image/casper/initrd

wget --progress=dot https://memtest.org/download/v7.00/mt86plus_7.00.binaries.zip -O /image/install/memtest86.zip
unzip -p /image/install/memtest86.zip memtest64.bin > /image/install/memtest86+.bin
unzip -p /image/install/memtest86.zip memtest64.efi > /image/install/memtest86+.efi
rm -f /image/install/memtest86.zip

# Configuración de GRUB
touch /image/inatux

cat <<EOF > /image/isolinux/grub.cfg

search --set=root --file /inatux

insmod all_video

set default="0"
set timeout=10

menuentry "Try Inatux FS without installing" {
   linux /casper/vmlinuz boot=casper nopersistent toram quiet splash ---
   initrd /casper/initrd
}

menuentry "Install Inatux FS" {
   linux /casper/vmlinuz boot=casper only-ubiquity quiet splash ---
   initrd /casper/initrd
}

menuentry "Check disc for defects" {
   linux /casper/vmlinuz boot=casper integrity-check quiet splash ---
   initrd /casper/initrd
}

grub_platform
if [ "\$grub_platform" = "efi" ]; then
menuentry 'UEFI Firmware Settings' {
   fwsetup
}

menuentry "Test memory Memtest86+ (UEFI)" {
   linux /install/memtest86+.efi
}
else
menuentry "Test memory Memtest86+ (BIOS)" {
   linux16 /install/memtest86+.bin
}
fi
EOF

# Crear manifest
dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee /image/casper/filesystem.manifest

cp -v /image/casper/filesystem.manifest image/casper/filesystem.manifest-desktop
sed -i '/ubiquity/d' /image/casper/filesystem.manifest-desktop
sed -i '/casper/d' /image/casper/filesystem.manifest-desktop
sed -i '/discover/d' /image/casper/filesystem.manifest-desktop
sed -i '/laptop-detect/d' /image/casper/filesystem.manifest-desktop
sed -i '/os-prober/d' /image/casper/filesystem.manifest-desktop

# Crear diskdefines
cat <<EOF > /image/README.diskdefines
#define DISKNAME  Ubuntu from scratch
#define TYPE  binary
#define TYPEbinary  1
#define ARCH  amd64
#define ARCHamd64  1
#define DISKNUM  1
#define DISKNUM1  1
#define TOTALNUM  0
#define TOTALNUM0  1
EOF

# Crear la imagen
cd /image

cp /usr/lib/shim/shimx64.efi.signed.previous isolinux/bootx64.efi
cp /usr/lib/shim/mmx64.efi isolinux/mmx64.efi
cp /usr/lib/grub/x86_64-efi-signed/grubx64.efi.signed isolinux/grubx64.efi

(
   cd isolinux && \
   dd if=/dev/zero of=efiboot.img bs=1M count=10 && \
   mkfs.vfat -F 16 efiboot.img && \
   LC_CTYPE=C mmd -i efiboot.img efi efi/ubuntu efi/boot && \
   LC_CTYPE=C mcopy -i efiboot.img ./bootx64.efi ::efi/boot/bootx64.efi && \
   LC_CTYPE=C mcopy -i efiboot.img ./mmx64.efi ::efi/boot/mmx64.efi && \
   LC_CTYPE=C mcopy -i efiboot.img ./grubx64.efi ::efi/boot/grubx64.efi && \
   LC_CTYPE=C mcopy -i efiboot.img ./grub.cfg ::efi/ubuntu/grub.cfg
)

grub-mkstandalone \
   --format=i386-pc \
   --output=isolinux/core.img \
   --install-modules="linux16 linux normal iso9660 biosdisk memdisk search tar ls" \
   --modules="linux16 linux normal iso9660 biosdisk search" \
   --locales="" \
   --fonts="" \
   "boot/grub/grub.cfg=isolinux/grub.cfg"

cat /usr/lib/grub/i386-pc/cdboot.img isolinux/core.img > isolinux/bios.img

/bin/bash -c "(find . -type f -print0 | xargs -0 md5sum | grep -v -e 'isolinux' > md5sum.txt)"

# Hacer limpieza
truncate -s 0 /etc/machine-id

rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

apt-get clean
rm -rf /tmp/* ~/.bash_history
umount /proc
umount /sys
umount /dev/pts
export HISTSIZE=0
exit

sudo umount $chrootdir/dev
sudo umount $chrootdir/run

# Comprimir chroot
cd $builddir 
sudo mv chroot/image .

sudo mksquashfs chroot image/casper/filesystem.squashfs \
   -noappend -no-duplicates -no-recovery \
   -wildcards \
   -comp xz -b 1M -Xdict-size 100% \
   -e "var/cache/apt/archives/*" \
   -e "root/*" \
   -e "root/.*" \
   -e "tmp/*" \
   -e "tmp/.*" \
   -e "swapfile"

printf $(sudo du -sx --block-size=1 chroot | cut -f1) | sudo tee image/casper/filesystem.size

# Hacer la iso para live CD
cd $builddir/image

sudo xorriso \
   -as mkisofs \
   -iso-level 3 \
   -full-iso9660-filenames \
   -J -J -joliet-long \
   -volid "Ubuntu from scratch" \
   -output "../ubuntu-from-scratch.iso" \
   -eltorito-boot isolinux/bios.img \
     -no-emul-boot \
     -boot-load-size 4 \
     -boot-info-table \
     --eltorito-catalog boot.catalog \
     --grub2-boot-info \
     --grub2-mbr ../chroot/usr/lib/grub/i386-pc/boot_hybrid.img \
     -partition_offset 16 \
     --mbr-force-bootable \
   -eltorito-alt-boot \
     -no-emul-boot \
     -e isolinux/efiboot.img \
     -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b isolinux/efiboot.img \
     -appended_part_as_gpt \
     -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
     -m "isolinux/efiboot.img" \
     -m "isolinux/bios.img" \
     -e '--interval:appended_partition_2:::' \
   -exclude isolinux \
   -graft-points \
      "/EFI/boot/bootx64.efi=isolinux/bootx64.efi" \
      "/EFI/boot/mmx64.efi=isolinux/mmx64.efi" \
      "/EFI/boot/grubx64.efi=isolinux/grubx64.efi" \
      "/EFI/ubuntu/grub.cfg=isolinux/grub.cfg" \
      "/isolinux/bios.img=isolinux/bios.img" \
      "/isolinux/efiboot.img=isolinux/efiboot.img" \
      "."

