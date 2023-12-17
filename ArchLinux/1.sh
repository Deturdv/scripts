#!/bin/bash

#Disk Scan
disk=$(sfdisk -l /dev/sda | grep -o '^/dev/sda[0-9]')
if [[ $disk == *"/dev/sda1"* && $disk == *"/dev/sda2"* && $disk == *"/dev/sda3"* ]]; then
        true
else
        echo "You have not created a disk or the partitions are incorrect"
fi

# mount
#mount /dev/sda2 /mnt # This is /
#mkdir /mnt/efi
#mount /dev/sda1 /mnt/efi # This is EFI
#mkdir /mnt/home
#mount /dev/sda3 /mnt/home # This is home


#stop reflector
systemctl stop reflector.service >/dev/null 2>&1

# 
ping -c 1 www.gnu.org &> /dev/null
if [ $? -ne 0 ]; then
  echo "[ Ping www.gnu.org Failed ]"
  exit
fi
echo "[ Ping www.gnu.org Succeeded ]"



# Time
timedatectl set-ntp true
timedatectl status | awk '/Local time|Time zone/ {print $0}'


# /pacman.d/mirrorlist
sed -i '10,30d' /etc/pacman.d/mirrorlist 		#clear 10 to 30 line
echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist


# update database and install base system
echo "Updating source and install base system...."
rm -rf /tmp/*
pacman -Syy
if [ $? -ne 0 ]; then
	Error "Bad network! Run the script again!"
fi

pacstrap /mnt base base-devel linux linux-headers linux-firmware dhcpcd iwd vim bash-completion
if [ $? -ne 0  ]; then
	Error "Bad network! Run the script again!"
fi

# generate fstab and get chroot script to run

echo
echo
echo "Generating fstab and prepare to chroot...."
sed -i '6,10d' /mnt/etc/fstab
genfstab -U -p /mnt >> /mnt/etc/fstab


