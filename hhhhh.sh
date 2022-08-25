#!/bin/bash
clear
#Checking for stuff
#Is on default installation thing?
touch installLog.log
cat /etc/issue | grep "Arch Linux" &> installLog.log
if [ $? != 0 ]; then
    echo "An error occured, unsupported OS, please use this script only in the default Arch Linux install environment!"
    exit 0
else
    clear
fi
#Is run with root?
whoami | grep "root" &> installLog.log 
if [ $? != 0 ]; then
    echo "An error occured, please run the script as root!"
    exit 0
else
    clear
fi

#Check if the system is UEFI
ls /sys/firmware/efi

if [ $? != 0 ]; then #Is BIOS
    touch EFI.txt
    echo 0 > EFI.txt
else   
    touch EFI.txt
    echo 1 > EFI.txt #Is UEFI
fi
efi=$(cat EFI.txt)

clear

echo "Installing dependencies, please wait..."
pacman -S dialog util-linux sed --noconfirm &> /dev/null

clear

#Begin ncurses thing

dialog --title "Archie installer" --msgbox "Welcome to the Archie installer!" 5 36

#Select Disk

diskcount=$(lsblk -nd --output NAME | wc -l)
touch disks.txt
lsblk -nd --output NAME,SIZE > disks.txt
disks=$(cat disks.txt | column -t -N "DISK,SIZE")

diskf(){
    dialog --no-cancel --no-collapse  --title "Select a DISK:" --inputbox "$disks" $((diskcount + 7)) 40 2> disk.txt
    seldisk=$(cat disk.txt)
    lsblk -nd --output NAME | grep -s $seldisk &> /dev/null

}
diskf
while [ $? != 0 ]; do
    dialog --title "Select s Disk" --msgbox "Error: Invalid disk, please enter a valid disk\n\nHINT:The names of the available disks are shown under the DISK column" 10 50
    
    diskf
done

echo "Selected disk is $seldisk" >> instalLog.log

dialog --no-cancel --title "Archie installer" --menu "Selected disk is: /dev/$seldisk/\n How do you wanna partition the disk?" 15 55 5 \ 1 "Automatic partitioning" \ 2 "Manual partitioning" 2> part.txt
part=$(cat part.txt)

if [ $part == 1 ]; then
    echo "mqn"
fi
if [ $part == 2 ]; then #Manual partitioning
        dialog --title "WARNING" --yesno "Selecting YES here WILL DELETE ALL THE DATA on the selected disk (/dev/$seldisk/)" 10 85
        #Add a wipefs command here
    if [ $efi == 1 ]; then #If UEFI
        if [ $? == 1 ]; then #If NO is selected on the delete all data prompt
            clear
            echo "Aborting..."
            exit 1
        fi
        dialog --title "Archie installer" --msgbox "You have chosen to manually partition the disks.\n\nHint: The installer has detected that you are on an UEFI system, meaning that you need to choose the GPT partition scheme and create at least 2 partitions (a root and an efi one) for the system to function properly\n\nPress ENTER to start configuring the selected disk (/dev/$seldisk/)"   15 80
        cfdisk /dev/$seldisk
        dsp=$(fdisk -l /dev/$seldisk | grep "/dev")
        parts1(){ #check root
            dialog --no-cancel --no-collapse --title "Select root (/) partition" --inputbox "$dsp" 10 90 2> rootpart.txt
            partcheck=$(cat rootpart.txt)
            fdisk -l /dev/$seldisk | sed 1d | grep -w $partcheck 
        }
        parts2(){ #check efi
            dialog --no-cancel --no-collapse --title "Select EFI (/boot/efi) partition" --inputbox "$dsp" 10 90 2> efipart.txt
            partcheck=$(cat efipart.txt)
            fdisk -l /dev/$seldisk | sed 1d | grep -w $partcheck 
        }
        parts3(){ #check swap
            dialog --no-cancel --no-collapse --title "Select swap partition (optional, type skip to skip)" --inputbox "$dsp" 10 90 2> swappart.txt
            partcheck=$(cat swappart.txt)
            fdisk -l /dev/$seldisk | sed 1d | grep -w $partcheck 
            cat swappart.txt | grep "skip"
        }
        parts4(){ #check home
            dialog --no-cancel --no-collapse --title "Select home partition (/home, optional, type skip to skip)" --inputbox "$dsp" 10 90 2> homepart.txt
            partcheck=$(cat homepart.txt)
            fdisk -l /dev/$seldisk | sed 1d | grep -w $partcheck 
            cat homepart.txt | grep "skip"

        }
        #can you tell i hate partitioning yet? THIS SUCKS, I DON'T WANNA USE 10000 WHILES but idk how to do it in a better way...
        parts1
        while [ $? != 0 ]; do
            dialog --title "Error" --msgbox "You have entered an invalid partition, please try again"
            parts1
        done
        parts2
        while [ $? != 0 ]; do
            dialog --title "Error" --msgbox "You have entered an invalid partition, please try again"
            parts2
        done
        parts3
        while [ $? != 0 ]; do
            dialog --title "Error" --msgbox "You have entered an invalid partition, please try again"
            parts3
        done
        parts4
        while [ $? != 0 ]; do
            dialog --title "Error" --msgbox "You have entered an invalid partition, please try again"
            parts4
        done
        #Partition creation
        dialog --title "Archie installer" --msgbox "Partitions that will be created:\n\nRoot (/): `cat rootpart.txt`\nEFI:`cat efipart.txt`\nSwap:`cat swappart.txt`\nHome:`cat swappart.txt`" 10 50

        mkfs.ext4 "`cat rootpart.txt`" && mkfs.fat -F32 "`cat efipart.txt`" && mount "`cat rootpart.txt`" /mnt && mkdir /mnt/boot/efi && mount "`cat efipart.txt`" /mnt/boot/efi
        if [ "`cat swappart.txt`" != "skip" ]; then
            mkswap "`cat swappart.txt`" &&  swapon "`cat swappart.txt`"
        fi
        if [ "`cat homepart.txt`" != skip ]; then
            mkfs.ext4 "`cat homepart.txt`"  && mount "`cat homepart.txt`" /mnt/home
        fi



    fi
    if [ $efi == 0 ]; then #If BIOS
        dialog --title "Archie installer" --msgbox "You have chosen to manually partition the disks.\n\nPress ENTER to start configuring the selected disk (/dev/$seldisk/)"   15 80
        cfdisk /dev/$seldisk
        dsp=$(fdisk -l /dev/$seldisk | grep "/dev")
        parts1(){ #check root
            dialog --no-cancel --no-collapse --title "Select root (/) partition" --inputbox "$dsp" 10 90 2> rootpart.txt
            partcheck=$(cat rootpart.txt)
            fdisk -l /dev/$seldisk | sed 1d | grep -w $partcheck 
        }
        parts3(){ #check swap
            dialog --no-cancel --no-collapse --title "Select swap partition (optional, type skip to skip)" --inputbox "$dsp" 10 90 2> swappart.txt
            partcheck=$(cat swappart.txt)
            fdisk -l /dev/$seldisk | sed 1d | grep -w $partcheck 
            cat swappart.txt | grep "skip"
        }
        parts1
        while [ $? != 0 ]; do
            dialog --title "Error" --msgbox "You have entered an invalid partition, please try again"
            parts1
        done
        parts3
        while [ $? != 0 ]; do
            dialog --title "Error" --msgbox "You have entered an invalid partition, please try again"
            parts3
        done
        
    fi
fi




