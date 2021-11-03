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
    exit 0
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

#Set file system/Create partitions

clear
echo "Select the disk where you want to install"
echo "[EXAMPLE: /dev/sda] "
echo ""
lsblk
read -p "Enter your choice:" dsk
echo ""
echo You have chosen $dsk as your instalation disk
echo ""
echo "How to you want your disk to be formatted?"
echo "[WARNING: THIS WILL DELETE ALL DATA ON THE DISK!]"
echo ""
echo "1 - Auto (This will do EVERYTHING automatically)" #OMG this script has AUTO in it
echo "2 - BIOS/dos (For older computers)"
echo "3 - EFI/gpt (For newer computers)"
echo "4 - I will do it myself (Will not delete any data)"
echo ""
read -p "Enter your choice: " efi
if [ $efi -eq 1 ]; then #Auto
    dmesg | grep "EFI v"
    if [ $? -eq 0 ]; then #If EFI
        clear
        echo "You are using an EFI system!"
        echo "[WARNING: Pressing ENTER will delete all data on the selected disk]"
        read -p "Press ENTER to continue setting up disks..." xd
        touch sfdisk.txt
        echo "label: GPT" >> sfdisk.txt
        echo ",300M, U"  >> sfdisk.txt
        read -p "Do you want a swap partition [y/n]? " swp
        if [ $swp = "y" ]; then #Yes Swap
            echo ",4G, S" >> sfdisk.txt
        elif [ $swp = "n" ]; then #No Swap
            echo "You have selected not to have a swap partition"
            echo ""
            echo "Press ENTER to continue..."
            read qqqq
        else
            echo "ERROR, not recognized, EXITTING"
            exit 0
        fi
        echo ",, L" >> sfdisk.txt
        wipefs -a $dsk
        sfdisk $dsk < sfdisk.txt
        rm sfdisk.txt
        clear
        echo "Partitions created successfully "
    else #If DOS
        clear
        echo "You are using a DOS system!"
        echo "[WARNING: Pressing ENTER will delete all data on the selected disk]"
        read -p "Press ENTER to continue setting up disks..." xd
        touch sfdisk.txt
        echo "label: DOS" >> sfdisk.txt
        read "Do you want a swap partition [y/n]? " swp
        if [ $swp = "y" ]; then #Yes Swap
            echo ",4G, S" >> sfdisk.txt
        elif [ $swp = "n" ]; then #No Swap
            echo "You have selected not to have a swap partition"
            echo ""
            echo "Press ENTER to continue..."
            read qqqq
        else
            echo "ERROR, not recognized, EXITTING"
            exit 0
        fi
        echo ",, L *" >> sfdisk.txt
        wipefs -a $dsk
        sfdisk $dsk < sfdisk.txt
        rm sfdisk.txt
        clear
        echo "Partitions created successfully "
    fi #Auto end

elif [ $efi -eq 2 ]; then #BIOS
    clear
    echo "You have selected that you have a BIOS system"
    echo "[WARNING: Pressing ENTER will delete all data on the selected disk]"
    read -p "Press ENTER to continue setting up disks..." xd
    touch sfdisk.txt
    echo "label: DOS" >> sfdisk.txt
    read -p "Do you want a swap partition [y/n]? " swp
    if [ $swp = "y" ]; then #Yes Swap
        echo ",4G, S" >> sfdisk.txt
    elif [ $swp = "n" ]; then #No Swap
        echo "You have selected not to have a swap partition"
        echo ""
        echo "Press ENTER to continue..."
        read qqqq
    else
        echo "ERROR, not recognized, EXITTING"
           exit 0
    fi
    echo ",, L *" >> sfdisk.txt
    wipefs -a $dsk
    sfdisk $dsk < sfdisk.txt
    rm sfdisk.txt
    clear
    echo "Partitions created successfully " #BIOS End

elif [ $efi -eq 3 ]; then #EFI
    clear
    echo "You have selected that you have an UEFI system"
    echo "[WARNING: Pressing ENTER will delete all data on the selected disk]"
    read -p "Press ENTER to continue setting up disks..." xd
    touch sfdisk.txt
    echo "label: GPT" >> sfdisk.txt
    echo ",300M, U"  >> sfdisk.txt
    read -p "Do you want a swap partition [y/n]? " swp
    if [ $swp = "y" ]; then #Yes Swap
        echo ",4G, S" >> sfdisk.txt
    elif [ $swp = "n" ]; then #No Swap
        echo "You have selected not to have a swap partition"
        echo ""
        echo "Press ENTER to continue..."
        read qqqq
    else
        echo "ERROR, not recognized, EXITTING"
        exit 0
    fi
    echo ",, L" >> sfdisk.txt
    wipefs -a $dsk
    sfdisk $dsk < sfdisk.txt
    rm sfdisk.txt
    clear
    echo "Partitions created successfully "

elif [ $efi -eq 4 ]; then #I will do it myself
    clear
    echo "You have selected that you want to setup partitions yourself"
    echo "-------------------------------------------------------------------"
    read -p "Do you want to erase the existing file system on the disk? [y/n] " wi
    if [ $wi = y ]; then
        wipefs -a $dsk
        clear
        echo "Filesystem Wiped!"
        echo "-------------------------------------------------------------------"
        read -p "Press ENTER to view cfdisk..." jk
        cfdisk $dsk
        clear
        read -p "Press ENTER to view changes to disks..." jk
        echo "-------------------------------------------------------------------"
        fdisk -l
        echo "-------------------------------------------------------------------"
        read -p "Press ENTER to continue..." jk
    elif [ $wi = n ]; then
        read -p "Press ENTER to view cfdisk..." jk
        cfdisk $dsk
        clear
        read -p "Press ENTER to view changes to disks..." jk
        echo "-------------------------------------------------------------------"
        fdisk -l
        echo "-------------------------------------------------------------------"
        read -p "Press ENTER to continue..." jk
    fi

fi
#Partition
touch tempdisk.txt
mqn = fdisk -l $dsk | grep '4G' | cut -d' ' -f1
clear
echo $mqn
exit 0
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






