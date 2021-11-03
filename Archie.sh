#!/usr/bin/env bash
clear
echo "Welcome to Archie! A simple terminal based installer for Arch linux"
echo "-------------------------------------------------------------------"
echo "Make sure you have a network connection before proceeding with the install"
echo "Press enter to begin"
read pressenter
#Check Internet
clear
echo "Checking internet availability..."
ping google.com -c 1
if [ $? -eq 0 ]; then
    echo "-------------------------------------------------------------------"
    echo "Internet connection succeeded!"
    read -p "Press any ENTER to continue..." zz
else
    echo "-------------------------------------------------------------------"
    echo "Internet connection failed, please connect to the internet and rerun the script!"
    read -p "Press any ENTER to exit..." zzz
    pacman -##### #Very big brain way to end the script i know
fi

#Disclaimer

clear
echo ""
echo "IMPORTANT!"
echo "-------------------------------------------------------------------"
echo "The installer does not check what you have entered."
echo "Make sure to follow all instructions carefully."
echo "If the script errors out or you mistype something"
echo "do ctrl + c to stop it echo and type |bash Archie.sh|"
echo "-------------------------------------------------------------------"
echo "Press enter to continue..."
read er
pacman -S vi --noconfirm

#Partition

clear
echo "Let's begin by partitioning our disks."
echo "-------------------------------------------------------------------"
echo "If you don't know what to do here, "
echo "Type 1 and hit enter to view the partitioning help..."
echo ""
echo "Press enter to continue without viewing the help file..."
read help
if [ $help -eq 1 ]
then
    vi PARTHELP.txt
    echo "Press enter to enter the partition tool"
    read ex
fi
cfdisk

#Set file system

clear
echo "Now, you need to setup your partitions"
echo "Enter partitions like this:"
echo "[EXAMPLE: /dev/sda1, where /sda1 is the partition you want to enter.]"
echo "-------------------------------------------------------------------"
echo "Press enter to view partitions and disks..."
read irt
fdisk -l
echo "-------------------------------------------------------------------"
read -p "Enter root partition: " rootpart
read -p "Enter swap partition (just press enter if none): " swappart 
read -p "Enter EFI partition (just press enter if none): " efipart 
mkfs.ext4 $rootpart
mkswap $swappart
mkfs.fat -F32 $efipart
mount $rootpart /mnt
swapon $swappart

#TimedatectNTP

timedatectl set-ntp true

#Country

clear
echo ""
echo ""
read -p "Enter your country. You can also use abreviations like BG or US (1st letter should be capital): " country

#Reflector

pacman -S reflector --noconfirm
reflector -c $country -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist

#Install Arch Linux

clear
echo "Select a kernel type"
echo "[If unsure, chose option 1]"
echo "-------------------------------------------------------------------"
echo "1 - Linux"
echo "2 - Linux-LTS"
echo "3 - Linux-Zen"
echo "4 - Linux-Hardened"
echo ""
read -p "Enter your choice: " gr
if [ $gr -eq 1 ]
then
    pacstrap /mnt base linux linux-firmware base-devel linux-headers nano
elif [ $gr -eq 2 ]
then
    pacstrap /mnt base linux-lts linux-firmware base-devel linux-lts-headers nano
fi
if [ $gr -eq 3 ]
then
    pacstrap /mnt base linux-zen linux-firmware base-devel linux-zen-headers nano
elif [ $gr -eq 4 ]
then
    pacstrap /mnt base linux-hardened linux-firmware base-devel linux-hardened-headers nano
fi

#Stab!

genfstab -U /mnt >> /mnt/etc/fstab

#Wayland or Xorg
clear
echo "Select your graphics platform"
echo "[If unsure select option 1]"
echo "-------------------------------------------------------------------"
echo "WARNING: Wayland will work with Nvidia, but it's known to have issues"
echo "-------------------------------------------------------------------"
echo "1 - Xorg/X11"
echo "2 - Wayland"
echo "-------------------------------------------------------------------"
read -p "Enter your choice: " xw
if [ $xw -eq 1 ]
then
    cp -r Archie2/ /mnt
    cp /mnt/Archie2/Archie2.sh /mnt
    chmod +rx /mnt/Archie2.sh
    arch-chroot /mnt /bin/bash -c ./Archie2.sh
elif [ $xw -eq 2 ]
then
    cp -r Archie2/ /mnt
    cp /mnt/Archie2/Archie2-Wayland.sh /mnt
    chmod +rx /mnt/Archie2-Wayland.sh
    arch-chroot /mnt /bin/bash -c ./Archie2-Wayland.sh
fi
#Proceed to Archie2






