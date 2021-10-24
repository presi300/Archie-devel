#!/usr/bin/env bash

#Wayland chosen
clear
echo "You have chosen Wayland as your graphics platform"
echo "-------------------------------------------------------------------"

#Enter hostname

echo ""
echo "Now, let's continue by entering a hostname"
echo "CANNOT HAVE UPPERCASE LETTERS OR SPECIAL CHARACTERS LIKE #!@ AND OTHERS"
echo "-------------------------------------------------------------------"
echo "Reccommended: archie"
echo ""
read -p "Enter hostname: " hostname

#Timezone
clear
echo ""
echo "Enter which continent you are currently in"
echo "[1st letter should be capital]"
echo ""
read -p "Enter continent: " continent

echo ""
echo "Enter which city you are in [Or the capital of your country] (1st letter should be capital)"
echo "For cities with more than one word in their name shound have an underscore between the names"
echo "-------------------------------------------------------------------"
echo "[EXAMPLE: New_York]"
echo ""
read -p "Enter city: " city

timedatectl set-timezone $continent/$city

#GPT or MBR

echo ""
echo "Now select if you have a BIOS or UEFI"
echo ""
echo "Chose 1 if you chose [dos] previously in the instalation"
echo "Chose 2 if you chose [gpt] previously in the instalation"
echo "-------------------------------------------------------------------"
echo "1 - BIOS"
echo "2 - UEFI"
echo ""
read -p "Enter choice: " bios


#Locale gen

echo LANG="en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

#Hostname

echo $hostname > /etc/hostname
touch /etc/hosts
echo 127.0.0.1      localhost >> /etc/hosts
echo ::1            localhost >> /etc/hosts
echo 127.0.1.1      $hostname >> /etc/hosts

#DHCP
pacman -S dhcp --noconfirm
pacman -S dhcpcd --noconfirm
systemctl enable dhcpcd

#GRUB

if [ $bios -eq 1 ]
then
    clear
    echo "You have selected BIOS previously in the instalation."
    echo "Press enter to view disks and partitions..."
    echo "-------------------------------------------------------------------"
    read a
    fdisk -l
    echo "-------------------------------------------------------------------"
    echo "Now enter the disk where you are installing arch linux to. DISK NOT PARTITION"
    echo "-------------------------------------------------------------------"
    echo "[EXAMPLE: /dev/sda]"
    echo ""
    read -p "Enter disk: " bdisk
    pacman -S grub os-prober --noconfirm
    grub-install $bdisk
    grub-mkconfig -o /boot/grub/grub.cfg
elif [ $bios -eq 2 ]
then
    clear
    echo "You have selected UEFI previously in the instalation."
    echo "Press enter to view disks and partitions..."
    echo "-------------------------------------------------------------------"
    read b
    fdisk -l
    echo "-------------------------------------------------------------------"
    echo "Now enter your EFI partition."
    echo "The EFI partition is usually the smallest one at around ~500MB"
    echo "-------------------------------------------------------------------"
    echo "[EXAMPLE: /dev/sda1]"
    echo ""
    read -p "Enter EFI partition: " efdisk
    pacman -S grub efibootmgr --noconfirm
    mkdir /boot/efi
    mount $efdisk /boot/efi
    grub-install --target=x86_64-efi --bootloader-id=ARCH --efi-directory=/boot/efi
    grub-mkconfig -o /boot/grub/grub.cfg
fi

#Username

clear
echo ""
echo ""
echo "Alright, everything is now configured"
echo "However we still have some finishing up to do"
echo "-------------------------------------------------------------------"
echo "Set a root password. "
passwd
echo ""
read -p "Enter a username (has the same limitations hostname): " username
useradd -mG wheel $username
echo ""
echo "Now set a password for the user:"
passwd $username

#Neofetch

pacman -S neofetch --noconfirm
neofetch
clear
rm ~/.config/neofetch/config.conf
cp /Archie2/config.conf ~/.config/neofetch/
rm /usr/bin/neofetch
cp /Archie2/neofetch /usr/bin/
chmod +rx /usr/bin/neofetch

#Sudo (ENORMOUS BRAIN TIME)

pacman -S sudo --noconfirm
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

#Uncomment multilib (AGAIN ENORMOUS BRAIN TIME)

echo "[multilib]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
pacman -Syy

#Desktop

clear
echo "Alright, almost there"
echo ""
echo "What desktop environment would you want:"
echo "-------------------------------------------------------------------"
echo "1 - KDE Plasma"
echo "2 - Gnome"
echo "-------------------------------------------------------------------"
read -p "Enter your choice: " DE
if [ $DE -eq 1 ] #KDE
then
    echo ""
    echo "You have chosen the KDE Plasma desktop environment"
    echo "Press enter to proceed with installation..."
    read k
    pacman -S plasma-wayland-session plasma-wayland-protocols sddm plasma firefox konsole qt5 networkmanager dolphin bluez bluez-utils noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra git kate vlc --noconfirm
    systemctl enable sddm
    systemctl enable NetworkManager
elif [ $DE -eq 2 ] #Gnome
then
    echo ""
    echo "You have chosen the Gnome desktop environment"
    echo "Press enter to proceed with installation..."
    read g
    pacman -S gnome wayland gnome-tweaks gnome-nettool gnome-usage adwaita-icon-theme firefox vlc gedit archlinux-wallpaper gdm gnome-terminal networkmanager gparted git noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra --noconfirm
    systemctl enable gdm
    systemctl enable NetworkManager

fi

clear
echo "Alright, everything is complete!"
echo "Now let's get your graphics adapter properly setup."
echo "Please select yor graphics adapter."
echo "-------------------------------------------------------------------"
echo "1 - Nvidia"
echo "2 - Intel"
echo "3 - AMD"
echo "4 - This is a virtual machine"
echo "5 - Other/Do not setup"
echo "-------------------------------------------------------------------"
echo "Note: for Nvidia/Intel switchable graphics"
echo "Select option 2 or 5"
echo "-------------------------------------------------------------------"
read -p "Enter your choice: " gra
if [ $gra -eq 1 ]
then
    clear
    echo "Chose driver for Nvidia"
    echo "-------------------------------------------------------------------"
    echo "WARNING: The proprietary Nvidia driver is known to cause issues with wayland"
    echo "proceed at your own risk or install the open source Nouveau driver"
    echo "-------------------------------------------------------------------"
    echo "WARNING: For legacy Nvidia cards (Older than GTX 500 Series)"
    echo "you might experience issues with the proprietary driver"
    echo "-------------------------------------------------------------------"
    echo "Note: chosing the Nouveau open source driver might lead to significant"
    echo "performance loss in GPU intensive tasks (like gaming)"
    echo "-------------------------------------------------------------------"
    echo "1 - Nouveau"
    echo "2 - Proprietary driver"
    echo "-------------------------------------------------------------------"
    read -p "Enter your choice: " nv
    if [ $nv -eq 1 ]
    then
        pacman -S xf86-video-nouveau
    elif [ $nv -eq 2 ]
    then
        pacman -S nvidia nvidia-settings
    fi
elif [ $gra -eq 2 ]
then
    clear
    pacman -S xf86-video-intel --noconfirm
elif [ $gra -eq 3 ]
then
    clear
    pacman -S xf86-video-amdgpu --noconfirm
elif [ $gra -eq 4 ]
then
    clear
    pacman -S pacman -S open-vm-tools gtkmm3 --noconfirm
    systemctl enable vmtoolsd
    systemctl enable vmware-vmblock-fuse.service
elif [ $gra -eq 5 ]
then
    echo ""
fi

#Finish
clear
echo "Alright, all done."
echo "-------------------------------------------------------------------"
echo "Press enter to exit archie, then type reboot..."
read fin
exit
