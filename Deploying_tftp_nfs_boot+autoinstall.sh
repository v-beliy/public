#!/bin/bash
# tftpd-server+pxe-загрузчик+NFS для установки Linux Mint из локальной сети
# ==========================================================================
# Инструкцию выполнял на предварительно установленом UbuntuServer 16.04
# Все действия выполнял от пользователя root
# ================================ НАЧНЁМ ==================================
export IP_PXE=`ip addr | grep 164 | awk '{print $2}' | cut -f1 -d'/'`
echo -e "Trying APT update"
sleep 2
apt update
if [[ "$?" -eq "0" ]]
 then
  echo -e "APT hes been updated!" && echo -e "APT hes been updated!" > /root/deploying-pxe.log
 else
  echo -e "APT has NOT updated!" && echo -e "APT has NOT updated!" > /root/deploying-pxe.log
  exit 1
fi
# Создаем /root/uninstall_pxe+tftp+nfs.sh:
echo -e "Trying create uninstall_pxe+tftp+nfs.sh"
sleep 2
echo -e '#!/bin/bash
rm /root/deploying_tftp+nfs+pxe.sh
rm /etc/default/tftpd-hpa
apt remove --purge -y tftpd-hpa
rm /etc/default/tftpd-hpa
sed -i '/mint18/d' /etc/exports
apt remove --purge -y nfs-kernel-server
umount /root/bionic
rm -rf /root/bionic/
umount /root/mint18
rm -rf /root/mint18/
rm -rf /root/syslinux-4.04/
rm /root/linuxmint-18.3-xfce-64bit.iso
rm /root/mini.iso
rm /root/syslinux-4.04.tar.bz2
rm -rf /srv/' > /root/uninstall_pxe+tftp+nfs.sh && chmod +x /root/uninstall_pxe+tftp+nfs.sh
if [[ "$?" -eq "0" ]]
 then
  echo -e "The script uninstall_pxe+tftp+nfs.sh hes been created!" && echo -e "The script uninstall_pxe+tftp+nfs.sh hes been created!" >> /root/deploying-pxe.log
 else
  echo -e "The script uninstall_pxe+tftp+nfs.sh has NOT created!" && echo -e "The script uninstall_pxe+tftp+nfs.sh has NOT created!" >> /root/deploying-pxe.log
  exit 1
fi
# Устанавливаем tftp-сервер:
echo -e "Trying install tftp-server"
sleep 2
apt install -y tftpd-hpa
if [[ "$?" -eq "0" ]]
 then
  echo -e "tftpd-hpa has been installed!" && echo -e "tftpd-hpa has been installed!" >> /root/deploying-pxe.log
 else
  echo -e "tftpd-hpa has NOT installed!" && echo -e "tftpd-hpa has NOT installed!" >> /root/deploying-pxe.log
  exit 1
fi
# Перезаписываем конфиг tftpd-hpa
echo -e "Trying write tftp's config-file"
sleep 2
echo -e '# /etc/default/tftpd-hpa

TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"                                                                                                                                              TFTP_ADDRESS=":69"
TFTP_OPTIONS="--secure"' > /etc/default/tftpd-hpa
if [[ "$?" -eq "0" ]]
 then
  echo -e "tftpd-hpa's config-file has been writed!" && echo -e "tftpd-hpa's config-file has been writed!" >> /root/deploying-pxe.log
 else
  echo -e "tftpd-hpa's config-file has NOT writed!" && echo -e "tftpd-hpa's config-file has NOT writed!" >> /root/deploying-pxe.log
  exit 1
fi
# Запускаем tftpd и поставим его в автозагрузку:
echo -e "Trying start tftp"
sleep 2
systemctl start tftpd-hpa && systemctl enable tftpd-hpa
if [[ "$?" -eq "0" ]]
 then
  echo -e "tftpd-hpa has been started!" && echo -e "ftpd-hpa has been started!" >> /root/deploying-pxe.log
 else
  echo -e "tftpd-hpa has NOT started!" && echo -e "tftpd-hpa has NOT started!" >> /root/deploying-pxe.log
  exit 1
fi
# Устанавливаем поддержку Network File System (NFS):
echo -e "Trying install nfs-kernel-server"
sleep 2
apt install -y nfs-kernel-server
if [[ "$?" -eq "0" ]]
 then
  echo -e "nfs-kernel-server has been installed!" && echo -e "nfs-kernel-server has been installed!" >> /root/deploying-pxe.log
 else
  echo -e "nfs-kernel-server has NOT installed!" && echo -e "nfs-kernel-server has NOT installed!" >> /root/deploying-pxe.log
  exit 1
fi
# Запускаем NFS и ставим его в автозагрузку:
echo -e "Trying start nfs-kernel-server"
sleep 2
systemctl start nfs-kernel-server && systemctl enable nfs-kernel-server
if [[ "$?" -eq "0" ]]
 then
  echo -e "nfs-kernel-server has been started!" && echo -e "nfs-kernel-server has been started!" >> /root/deploying-pxe.log
 else
  echo -e "nfs-kernel-server has NOT started!" && echo -e "nfs-kernel-server has NOT started!" >> /root/deploying-pxe.log
  exit 1
fi
# Создаем папку для tftp:
echo -e "Trying create tftp's folder"
sleep 2
mkdir -p /srv/tftp
if [[ "$?" -eq "0" ]]
 then
  echo -e "The folder for tftp hes been created!" && echo -e "The folder for tftp hes been created!" >> /root/deploying-pxe.log
 else
  echo -e "The folder for tftp has NOT created!" && echo -e "The folder for tftp has NOT created!" >> /root/deploying-pxe.log
  exit 1
fi
# Скачиваем загрузчик syslinux:
echo -e "Trying download syslinux"
sleep 2
wget -P /root/ http://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-4.04.tar.bz2
if [[ "$?" -eq "0" ]]
 then
  echo -e "Syslinux has been downloaded!" && echo -e "Syslinux has been downloaded!" >> /root/deploying-pxe.log
 else
  echo -e "Syslinux has NOT downloaded!" && echo -e "Syslinux has NOT downloaded!" >> /root/deploying-pxe.log
  exit 1
fi
# Распаковываем загрузчик syslinux:
echo -e "Trying unpack syslinux"
sleep 2
tar xf /root/syslinux-4.04.tar.bz2
if [[ "$?" -eq "0" ]]
 then
  echo -e "Syslinux has been unpacked!" && echo -e "Syslinux has been unpacked!" >> /root/deploying-pxe.log
 else
  echo -e "Syslinux has NOT unpacked!" && echo -e "Syslinux has NOT unpacked!" >> /root/deploying-pxe.log
  exit 1
fi
# Копируем нужные файлы загрухчика на tftp и удаляем все остальное:
echo -e "Trying copy pxelinux.0"
sleep 2
cp /root/syslinux-4.04/core/pxelinux.0 /srv/tftp/
if [[ "$?" -eq "0" ]]
 then
  echo -e "The pxelinux.0 has been copied!" && echo -e "The pxelinux.0 has been copied!" >> /root/deploying-pxe.log
 else
  echo -e "The pxelinux.0 has NOT copied!" && echo -e "The pxelinux.0 has NOT copied!" >> /root/deploying-pxe.log
  exit 1
fi
echo -e "Trying copy chain.c32"
sleep 2
cp /root/syslinux-4.04/com32/modules/chain.c32 /srv/tftp/
if [[ "$?" -eq "0" ]]
 then
  echo -e "The chain.c32 has been copied!" && echo -e "The chain.c32 has been copied!" >> /root/deploying-pxe.log
 else
  echo -e "The chain.c32 has NOT copied!" && echo -e "The chain.c32 has NOT copied!" >> /root/deploying-pxe.log
  exit 1
fi
echo -e "Trying copy menu.c32"
sleep 2
cp /root/syslinux-4.04/com32/menu/menu.c32 /srv/tftp/
if [[ "$?" -eq "0" ]]
 then
  echo -e "The menu.c32 has been copied!" && echo -e "The menu.c32 has been copied!" >> /root/deploying-pxe.log
 else
  echo -e "The menu.c32 has NOT copied!" && echo -e "The menu.c32 has NOT copied!" >> /root/deploying-pxe.log
  exit 1
fi
 rm -rf /root/syslinux-4.04/ && rm /root/syslinux-4.04.tar.bz2
if [[ "$?" -eq "0" ]]
 then
  echo -e "Other files syslinux has been deleted!" && echo -e "Other files syslinux has been deleted!" >> /root/deploying-pxe.log
 else
  echo -e "Other files syslinux has NOT deleted!" && echo -e "Other files syslinux has NOT deleted!" >> /root/deploying-pxe.log
  exit 1
fi
# Создаем папку для менюшек загрузчика:
echo -e "Trying create the folder for loader's menu"
sleep 2
mkdir -p /srv/tftp/pxelinux.cfg
if [[ "$?" -eq "0" ]]
 then
  echo -e "The folder for loader's menu hes been created!" && echo -e "The folder for loader's menu has been created!" >> /root/deploying-pxe.log
 else
  echo -e "The folder for loader's menu has NOT created!" && echo -e "The folder for loader's menu has NOT created!" >> /root/deploying-pxe.log
  exit 1
fi
# Создаем файлы менюшек:
echo -e "Trying create default menu"
sleep 2
echo -e "ui menu.c32
PROMPT 0
MENU TITLE Network PXE boot menu by Aid ))

LABEL Linux distros
        KERNEL menu.c32
        APPEND pxelinux.cfg/linux
        timeout 100

LABEL bootlocal
        menu label Boot from first HDD
        kernel chain.c32
        append hd0 0" > /srv/tftp/pxelinux.cfg/default
if [[ "$?" -eq "0" ]]
 then
  echo -e "The default-menu has been created!" && echo -e "The default-menu has been created!" >> /root/deploying-pxe.log
 else
  echo -e "The default-menu has NOT created!" && echo -e "The default-menu has NOT created!" >> /root/deploying-pxe.log
  exit 1
fi
echo -e "Trying create linux menu"
sleep 2
echo -e "ui menu.c32
PROMPT 0
MENU TITLE Install Linux OS via network by Aid ))

LABEL Lan AUTO-install Linux Mint 18.3 by Aid ;))
        KERNEL vmlinuz
        APPEND showmounts root = /dev/nfs boot=casper netboot=nfs nfsroot="$IP_PXE":/srv/tftp/images/mint18/ file=/cdrom/preseed/autoinstall_by_aid.seed automatic-ubiquity console-setup/ask_detect=false auto=true priority=critical ubiquity/reboot=true quiet initrd=initrd.lz spalsh --
        timeout 100

LABEL Net-install Ubuntu Bionic
        KERNEL linux
        APPEND vga=788 initrd=initrd.gz --- quiet

LABEL Back to main menu
        KERNEL menu.c32
        APPEND pxelinux.cfg/default" > /srv/tftp/pxelinux.cfg/linux
if [[ "$?" -eq "0" ]]
 then
  echo -e "The linux-menu has been created!" && echo -e "The linux-menu has been created!" >> /root/deploying-pxe.log
 else
  echo -e "The linux-menu has NOT created!" && echo -e "The linux-menu has NOT created!" >> /root/deploying-pxe.log
  exit 1
fi
# Скачиваем linuxmint-18.3-xfce-64bit.iso:
echo -e "Trying download Linux Mint 18 iso"
sleep 2
wget -P /root/ http://linuxmint.ip-connect.vn.ua/stable/18.3/linuxmint-18.3-xfce-64bit.iso
if [[ "$?" -eq "0" ]]
 then
  echo -e "Linuxmint-18.3-xfce-64bit.iso has been downloaded!" && echo -e "linuxmint-18.3-xfce-64bit.iso has been downloaded!" >> /root/deploying-pxe.log
 else
  echo -e "Linuxmint-18.3-xfce-64bit.iso has NOT downloaded!" && echo -e "linuxmint-18.3-xfce-64bit.iso has NOT downloaded!" >> /root/deploying-pxe.log
  exit 1
fi
# Создаем временную папку для монтирования образа /root/mint18:
echo -e "Trying create folder for mounting Linux Mint distro"
sleep 2
mkdir -p /root/mint18
if [[ "$?" -eq "0" ]]
 then
  echo -e "The folder for mounting Linux Mint distro hes been created!" && echo -e "The folder for mounting Linux Mint distro has been created!" >> /root/deploying-pxe.log
 else
  echo -e "The folder for mounting Linux Mint distro has NOT created!" && echo -e "The folder for mounting Linux Mint distro has NOT created!" >> /root/deploying-pxe.log
  exit 1
fi
# Создаем папку для размещения образа Минта на сервере tftp:
echo -e "Trying create folder on tftp-server for Linux Mint distro"
sleep 2
mkdir -p /srv/tftp/images/mint18/extra
if [[ "$?" -eq "0" ]]
 then
  echo -e "The folder on tftp-server for Linux Mint distro hes been created!" && echo -e "The folder on tftp-server for Linux Mint distro has been created!" >> /root/deploying-pxe.log
 else
  echo -e "The folder on tftp-server for Linux Mint distro has NOT created!" && echo -e "The folder on tftp-server for Linux Mint distro has NOT created!" >> /root/deploying-pxe.log
  exit 1
fi
# Монтируем образ Минта во временную папку для копирования на сервер:
echo -e "Trying mount Linux Mint iso"
sleep 2
mount -o loop /root/linuxmint-18.3-xfce-64bit.iso /root/mint18/
if [[ "$?" -eq "0" ]]
 then
  echo -e "Linuxmint-18.3-xfce-64bit.iso has been mounted!" && echo -e "linuxmint-18.3-xfce-64bit.iso has been mounted!" >> /root/deploying-pxe.log
 else
  echo -e "Linuxmint-18.3-xfce-64bit.iso has NOT mounted!" && echo -e "linuxmint-18.3-xfce-64bit.iso has NOT mounted!" >> /root/deploying-pxe.log
  exit 1
fi
# Копируем содержимое смонтированого образа Минта на tftp-сервер:
echo -e "Trying copy the Linux Mint distro to tftp-server"
sleep 2
cp -rf /root/mint18/* /srv/tftp/images/mint18/
if [[ "$?" -eq "0" ]]
 then
  echo -e "The Linux Mint distro has been copied to tftp-server!" && echo -e "The Linux Mint distro has been copied to tftp-server!" >> /root/deploying-pxe.log
 else
  echo -e "The Linux Mint distro has NOT copied to tftp-server!" && echo -e "The Linux Mint distro has NOT copied to tftp-server!" >> /root/deploying-pxe.log
  exit 1
fi
# Размонтируем образ Минта, удаляем его и временную папку
umount /root/mint18/ && rm -rf /root/mint18/ && rm /root/linuxmint-18.3-xfce-64bit.iso
if [[ "$?" -eq "0" ]]
 then
  echo -e "Linuxmint-18.3-xfce-64bit.iso has been unmounted and deleted!" && echo -e "linuxmint-18.3-xfce-64bit.iso has been unmounted and deleted!" >> /root/deploying-pxe.log
 else
  echo -e "Linuxmint-18.3-xfce-64bit.iso has NOT unmounted and deleted!" && echo -e "linuxmint-18.3-xfce-64bit.iso has NOT unmounted and deleted!" >> /root/deploying-pxe.log
  exit 1
fi
# Копируем файлы ядра Минта в корень tftp:
echo -e "Trying copy kernel's files Linux Mint distro to tftp-server's root"
sleep 2
cp /srv/tftp/images/mint18/casper/{vmlinuz,initrd.lz} /srv/tftp/
if [[ "$?" -eq "0" ]]
 then
  echo -e "The kernel's files Linux Mint distro has been copied to tftp-server's root!" && echo -e "The kernel's files Linux Mint distro has been copied to tftp-server's root!" >> /root/deploying-pxe.log
 else
  echo -e "The kernel's files Linux Mint distro has NOT copied to tftp-server's root!" && echo -e "The kernel's files Linux Mint distro has NOT copied to tftp-server's root!" >> /root/deploying-pxe.log
  exit 1
fi
# Создаем скрипт postinstall.sh
echo -e "#!/bin/bash
adduser user <<EOF
RegularPass
RegularPass
EOF
echo $? > /root/postinstall.log | echo -e "n\Regular user log" >> /root/postinstall.log
passwd admin <<EOF
Admin$tandartP@ss
Admin$tandartP@ss
EOF
echo $? >> /root/postinstall.log | echo -e "n\n\Change tkadmin pass log" >> /root/postinstall.log
rm /root/google-chrome-stable_current_amd64.deb
rm /root/teamviewer_amd64.deb
mkdir -p /home/user/Рабочий\ стол/
echo $? >> /root/postinstall.log | echo -e "n\n\Creating Desktop folder log" >> /root/postinstall.log
echo -e '[Desktop Entry]
Version=1.0
Encoding=UTF-8
Type=Application
Categories=Network;

Name=TeamViewer
Comment=Remote control and meeting solution.
Exec=/opt/teamviewer/tv_bin/script/teamviewer

Icon=TeamViewer' > /home/user/Рабочий\ стол/com.teamviewer.TeamViewer.desktop
echo $? >> /root/postinstall.log | echo -e "n\n\Creating Teamviewer icon log" >> /root/postinstall.log
echo -e '[Desktop Entry]
Version=1.0
Name=Google Chrome
Comment[ru]=Доступ в Интернет
Exec=/usr/bin/google-chrome-stable %U
StartupNotify=true
Terminal=false
Icon=google-chrome
Type=Application
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/ftp;x-scheme-handler/http;x-scheme-handler/https;
Actions=new-window;new-private-window;

[Desktop Action new-window]
Name=New Window
Name[ru]=Новое окно
Exec=/usr/bin/google-chrome-stable

[Desktop Action new-private-window]
Name=New Incognito Window
Name[ru]=Новое окно в режиме инкогнито
Exec=/usr/bin/google-chrome-stable --incognito' > /home/user/Рабочий\ стол/google-chrome.desktop
echo $? >> /root/postinstall.log | echo -e "n\n\Creating Chrome icon log" >> /root/postinstall.log
echo -e '[Desktop Entry]
Version=1.0
Name=Remmina
GenericName=Remote Desktop Client
X-GNOME-FullName=Remmina Remote Desktop Client
Comment=Connect to remote desktops
TryExec=remmina
Exec=remmina
Icon=remmina
Terminal=false
Type=Application
Categories=GTK;GNOME;X-GNOME-NetworkSettings;Network;
Actions=Profile;Tray;
Keywords=remote desktop;rdp;vnc;nx,ssh;VNC;XDMCP;RDP;
X-Ubuntu-Gettext-Domain=remmina

[Desktop Action Profile]
Name=Create a New Connection Profile
Exec=remmina --new

[Desktop Action Tray]
Name=Start Remmina Minimized
Exec=remmina --icon' > /home/user/Рабочий\ стол/remmina.desktop
echo $? >> /root/postinstall.log | echo -e "n\n\Creating remmina icon log" >> /root/postinstall.log
chmod +x /home/user/Рабочий\ стол/*
chown user:user /home/user/Рабочий\ стол/*
chown -R user:user /home/user/Рабочий\ стол/
systemctl enable ocsinventory-agent
reboot" > /srv/tftp/images/mint18/extra/postinstall.sh
if [[ "$?" -eq "0" ]]
 then
  echo -e "The script postinstall.sh hes been created!" && echo -e "The postinstall.sh has been created!" >> /root/deploying-pxe.log
 else
  echo -e "The postinstall.sh has NOT created!" && echo -e "The postinstall.sh has NOT created!" >> /root/deploying-pxe.log
  exit 1
fi
# Создаем сценарий установки Минта
echo -e "Trying write Linux Mint instalation instruction"
sleep 2
echo -e 'd-i debian-installer/locale string ru_RU
d-i time/zone string Europe/Kiev
d-i console-setup/layoutcode string ru
d-i netcfg/choose_interface select auto

# Keyboard selection.
# Disable automatic (interactive) keymap detection.
d-i console-setup/ask_detect boolean false
d-i keyboard-configuration/layoutcode string ru

# Partitioning
d-i partman-auto/disk string /dev/sda
d-i partman-auto/method string regular
partman-auto partman-auto/init_automatically_partition select Guided - use entire disk
partman-auto partman-auto/automatically_partition select
d-i partman-auto/purge_lvm_from_device boolean true
d-i partman/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

# Account setup
d-i passwd/user-fullname string admin
d-i netcfg/get_hostname string mint-64bit
d-i passwd/username string admin
d-i passwd/user-password string 1
d-i passwd/user-password-again string 1
d-i passwd/auto-login boolean false
d-i user-setup/allow-password-weak boolean false

# Controls whether or not the hardware clock is set to UTC.
d-i clock-setup/utc boolean true

ubiquity ubiquity/use_nonfree boolean true
# if you want to start commands after the installation
ubiquity ubiquity/success_command string apt-get update -y; \
in-target wget -P /root/ https://download.teamviewer.com/download/linux/teamviewer_amd64.deb; \
in-target wget -P /root/ https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; \
in-target apt-get install -y ssh mc ncdu vim htop iftop screen tmux pv remmina remmina-plugin-rdp \
in-target apt-get install -y /root/teamviewer_amd64.deb; \
in-target apt-get install -y /root/google-chrome-stable_current_amd64.deb; \
cp -R /cdrom/extra/* /target/root/; \
mv /target/root/ocsinventory-agent.cfg /target/etc/ocsinventory/; \
chroot /target chmod 0700 /root/postinstall.sh; \
chroot /target sed -i 's/manual/dhcp/' /etc/network/interfaces; \
in-target service networking restart; in-target ocsinventory-agent

ubiquity ubiquity/summary note
ubiquity ubiquity/reboot boolean true' > /srv/tftp/images/mint18/preseed/autoinstall_by_aid.seed
if [[ "$?" -eq "0" ]]
 then
  echo -e "Linux Mint installation instruction has been created!" && echo -e "Linux Mint installation instruction has been created!" >> /root/deploying-pxe.log
 else
  echo -e "Linux Mint installation instruction has NOT created!" && echo -e "Linux Mint installation instruction has NOT created!" >> /root/deploying-pxe.log
  exit 1
fi
# Загружаем mini.iso образ установщика Ubuntu Bionuc (которая включает Xubuntu, Lubuntu)
echo -e "Trying download the Bionic installer as mini.iso"
sleep 2
wget -P /root/ http://archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/current/images/netboot/mini.iso
if [[ "$?" -eq "0" ]]
 then
  echo -e "The web-installer Ubuntu 18 Bionic has been downloaded!" && echo -e "The web-installer Ubuntu 18 Bionic has been downloaded!" >> /root/deploying-pxe.log
 else
  echo -e "The web-installer Ubuntu 18 Bionic has NOT downloaded!" && echo -e "The web-installer Ubuntu 18 Bionic has NOT downloaded!" >> /root/deploying-pxe.log
  exit 1
fi
# Создаем временную папку для монтирования образа mini.iso /root/bionic:
echo -e "Trying create folder for mounting web-installer Ubuntu 18 Bionic"
sleep 2
mkdir -p /root/bionic
if [[ "$?" -eq "0" ]]
 then
  echo -e "The folder for mounting web-installer Ubuntu 18 Bionic hes been created!" && echo -e "The folder for mounting web-installer Ubuntu 18 Bionic has been created!" >> /root/deploying-pxe.log
 else
  echo -e "The folder for mounting web-installer Ubuntu 18 Bionic has NOT created!" && echo -e "The folder for mounting web-installer Ubuntu 18 Bionic has NOT created!" >> /root/deploying-pxe.log
  exit 1
fi
# Монтируем образ mini.iso (bionuc) на сервер:
echo -e "Trying mount mini.iso"
sleep 2
mount -o loop /root/mini.iso /root/bionic/
if [[ "$?" -eq "0" ]]
 then
  echo -e "mini.iso has been mounted!" && echo -e "mini.iso has been mounted!" >> /root/deploying-pxe.log
 else
  echo -e "mini.iso has NOT mounted!" && echo -e "mini.iso has NOT mounted!" >> /root/deploying-pxe.log
  exit 1
fi
# Копируем файлы загрузчика Bionic в корень tftp:
echo -e "Trying copy Ubuntu 18 Bionic loader's files"
sleep 2
cp /root/bionic/{linux,initrd.gz} /srv/tftp/
if [[ "$?" -eq "0" ]]
 then
  echo -e "The Ubuntu 18 Bionic loader's files has been copied!" && echo -e "The loader's Ubuntu 18 Bionic files has been copied!" >> /root/deploying-pxe.log
 else
  echo -e "The loader's Ubuntu 18 Bionic files has NOT copied!" && echo -e "The loader's Ubuntu 18 Bionic files has NOT copied!" >> /root/deploying-pxe.log
  exit 1
fi
# Размонтируем образ mini.iso (bionuc), удаляем его и временную папку
umount /root/bionic/ && rm -rf /root/bionic/ && rm /root/mini.iso
if [[ "$?" -eq "0" ]]
 then
  echo -e "The mini.iso (bionuc) has been unmounted and deleted!" && echo -e "The mini.iso (bionuc) has been unmounted and deleted!" >> /root/deploying-pxe.log
 else
  echo -e "The mini.iso (bionuc) has NOT unmounted and deleted!" && echo -e "The mini.iso (bionuc) has NOT unmounted and deleted!" >> /root/deploying-pxe.log
  exit 1
fi
# Перезапускаем tftp-сервер:
echo -e "Trying restart tftpd-hpa"
sleep 2
systemctl restart tftpd-hpa
if [[ "$?" -eq "0" ]]
 then
  echo -e "The tftpd-hpa has been restarted!" && echo -e "The tftpd-hpa has been restarted!" >> /root/deploying-pxe.log
 else
  echo -e "The tftpd-hpa has NOT restarted!" && echo -e "The tftpd-hpa has NOT restarted!" >> /root/deploying-pxe.log
  exit 1
fi
# Настраиваем nfs-шару:
echo -e "Trying setup the NFS sharing"
sleep 2
echo -e "/srv/tftp/images/mint18/ *(ro,sync,no_wdelay,insecure_locks,no_root_squash,insecure)" >> /etc/exports
if [[ "$?" -eq "0" ]]
 then
  echo -e "The NFS sharing has been setaped!" && echo -e "The NFS sharing has been setaped!" >> /root/deploying-pxe.log
 else
  echo -e "The NFS sharing has NOT setaped!" && echo -e "The NFS sharing has NOT setaped!" >> /root/deploying-pxe.log
  exit 1
fi
# Перезапускаем nfs-kernel-server
echo -e "Trying restart nfs-kernel-server"
sleep 2
systemctl restart nfs-kernel-server
if [[ "$?" -eq "0" ]]
 then
  echo -e "The nfs-kernel-server has been restarted!" && echo -e "The nfs-kernel-server has been restarted!" >> /root/deploying-pxe.log
 else
  echo -e "The nfs-kernel-server has NOT restarted!" && echo -e "The nfs-kernel-server has NOT restarted!" >> /root/deploying-pxe.log
  exit 1
fi
# Чтоб посмотреть что расшарено по nfs, можно выполнить:
# showmount -e 192.168.1.1
# где 192.168.1.1 - это IP сервера с nfs-шарой
# Пробую загрузиться по сети )
echo -e "Now try to run the installation over the network"
