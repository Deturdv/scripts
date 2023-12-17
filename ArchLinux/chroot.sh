#!/bin/bash

#Setting Shanghai time zone
echo "Setting time zone...."
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

hwclock --systohc

#Create User
username=li 
if grep -q "^$username:" /etc/passwd; then #如果存在用户
        echo "$username:5210" | chpasswd # 使用 chpasswd 命令修改密码
        echo "user $username already exists!!!"
else
        useradd -m -G wheel -s /bin/bash $username 
        echo "$username:5210" | chpasswd # 
	echo "user $username is created successfully!!!"
fi

echo -e "\e[1;31m╔═══════════════════════╗\e[0m"
echo -e "\e[1;31m║ User Creation is Over ║\e[0m"
echo -e "\e[1;31m╚═══════════════════════╝\e[0m"

#install base softwares
#pikaur fcitx5-pinyin-moegirl
packages="konsole
plasma-meta
dolphin
sof-firmware
alsa-firmware
alsa-ucm-conf
adobe-source-han-serif-cn-fonts
wqy-zenhei
noto-fonts-cjk
noto-fonts-emoji
noto-fonts-extra
intel-ucode
amd-ucode
firefox chromium
ark
p7zip
unrar
unarchiver
lzop
lrzip
packagekit-qt5
packagekit
appstream-qt
appstream 
gwenview
git
wget
kate
bind
networkmanager
rp-pppoe
fcitx5-chinese-addons
fcitx5-anthy
fcitx5-material-color"

echo "Installing base softwares"
pacman -Syu --noconfirm  
pacman -S --needed --noconfirm $packages

echo -e "\e[1;31m╔═══════════════════════╗\e[0m"
echo -e "\e[1;31m║ Installation Complete ║\e[0m"
echo -e "\e[1;31m╚═══════════════════════╝\e[0m"

#DNS
chattr -i  /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 2001:4860:4860::8888" >> /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
echo "nameserver 2001:4860:4860::8844" >> /etc/resolv.conf
chattr +i  /etc/resolv.conf


#Setting  Local
echo "Configuring language...."
sed -i '/en_US.UTF-8/s/^#//;/zh_CN.UTF-8/s/^#//;/zh_CN.GBK GBK/s/^#//;/zh_CN GB2312/s/^#//' /etc/locale.gen
locale-gen


#System Language
echo 'LANG=en_US.UTF-8'  > /etc/locale.conf
echo '#LANG=zh_CN.UTF-8'  >> /etc/locale.conf

# Host Name
echo 'GARYEXY'  > /etc/hostname

#Hosts File
sed -i '3,10d' /etc/hosts
host='127.0.0.1   localhost\n::1         localhost\n127.0.1.1   myarch'
echo -e  "$host" >> /etc/hosts


#Root Password
echo "root:5210" | chpasswd 

# Grub
pacman -S efibootmgr grub --noconfirm
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg

# Input
echo 'export GTK_IM_MODULE=fcitx' >> /etc/profile
echo 'export QT_IM_MODULE=fcitx' >> /etc/profile
echo 'export XMODIFIERS="@im=fcitx"' >> /etc/profile


systemctl enable dhcpcd
systemctl enable ntpd
systemctl enable sddm
systemctl enable NetworkManager

sleep 3

#Reboot
echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger







