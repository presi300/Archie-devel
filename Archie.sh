#!/bin/bash
clear
#Checking for stuff
#Is on default installation thing?
touch installLog.log
cat /etc/issue | grep "Arch Linux" &> installLog.log
if [ $? != 0 ]; then #check if running on the official iso
    echo "An error occured, unsupported OS, please use this script only in the default Arch Linux install environment!"
    exit 0
else
    clear
fi
#Is run with root?
whoami | grep "root" &> installLog.log 
if [ $? != 0 ]; then #Check if is running as root
    echo "An error occured, please run the script as root!"
    exit 0
else
    clear
fi

#umount -a
#swapoff -a
rm autodisk.txt             #remove excess config files from a previous instance, if there was one
rm fdiskconfigshow.sh
rm fdiskconfig.sh
rm disk.txt
rm disks.txt
rm EFI.txt
rm installLog.log
rm part.txt
rn sephomesize.txt
rm swapsize.txt
rm yes.txt
rm isnvme.txt
rm packages.inst
rm GPU.txt
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

echo "Installing dependencies, please wait..."  #install dependencies
pacman -Syy dialog util-linux sed lshw --noconfirm &> /dev/null

clear

touch packages.inst     #Create the file for installed packages

#Begin ncurses thing

dialog --title "Archie installer" --msgbox "Welcome to the Archie installer!" 5 36

#Detect GPU

dialog --title "Wait..." --infobox "Detecting graphics adapter, please wait..." 5 50    #lshw is slow lol

lshw -numeric -C display &> lshw.txt    #Piping this command to a file because it's slow

gpucheck(){     #I got tired of copy pasting this horrible line, so here's a function for it
    cat lshw.txt  | grep "product:" | sed -e 's/^\w*\ *//' | sed 's,/[^/]*$,,' | sed 's/[:[]//g' | sed 's/[]]//g' | sed 's/\<product\>//g'  | sed -e 's/^[ \t]*//'
} 

cat lshw.txt | grep "AMD" &> installLog.log   #Check for AMD
if [ $? == 0 ]; then
    dialog --yes-label "Automatic" --no-label "Manual" --no-collapse --title "Archie installer" --yesno "The installer has detected AMD graphics! GPUs detected:\n\n`gpucheck`\n\n\n\nDo you want to proceed with automatic setup or do you wanna configure it by yourself later?\n\nNote: Choosing to configure it by yourself will mean that the installer will NOT install any X display drivers" 20 75  #Regex is my passion (idfk how sed works, i just throw stuff at it untill it works)
    if [ $? == 0 ]; then
        echo " xf86-video-amdgpu " >> packages.inst
        echo "AMD" > GPU.txt
    else [ $? != 0 ]
        echo "Manual" > GPU.txt
    fi
fi

cat lshw.txt | grep "NVIDIA" &> installLog.log   #Check for NVIDIA (Fuck you, Nvidia)
if [ $? == 0 ]; then
    nvidia=1
fi

cat lshw.txt | grep "Intel" &> installLog.log
if [ $? == 0 ]; then    #Check for Intel
    intel=1
    if [ $nvidia == 1 ]; then   #Check for both intel and nvidia
        dialog --no-canel --no-collapse --title "Archie installer" --menu "The installer has detected both Intel and Nvidia graphics! GPUs detected:\n\n`gpucheck`\n\nNote: As of right now the installer can't setup switchable graphics (I have no idea how to do that reliably and i have no way to test it currently), so if this screen appears and you're on a laptop, select either 'Use Intel graphics' or 'Manual configuration'" 60 70 4 1 "Use the Nvidia proprietaty driver" 2 "Use the Nvidia FOSS driver (Nouveau)" 3 "Use Intel graphics" 4 "Manual configuration" 2> nvidiachoice.txt
        nvidiachoice=$(cat nvidiachoice.txt)
        if [ $nvidiachoice == 1 ]; then     #Proprietary driver selected
            echo "NVIDIA Proprietary" > GPU.txt
            echo " nvidia nvidia-settings " >> packages.inst
        elif [ $nvidiachoice == 2 ]; then   #Nouveau selected
            echo "NVIDIA FOSS" > GPU.txt
            echo " xf86-video-nouveau " >> packages.inst    #Intel selected
        elif [ $nvidiachoice == 3 ]; then
            echo "Intel" > GPU.txt
            echo " xf86-video-intel " >> packages.inst      #Manual configuration selected
        elif [ $nvidiachoice == 4 ]; then
            echo "Manual" > GPU.txt
        fi
    elif [ $nvidia != 1 ]; then
        dialog --yes-label "Automatic" --no-label "Manual" --title "Archie installer" --yesno "The installer has detected Intel graphics! GPUs detected:\n\n`gpucheck`\n\n\n\nDo you want to proceed with automatic setup or do you wanna configure it by yourself later?\n\nNote: Choosing to configure it by yourself will mean that the installer will NOT install any X display drivers" 20 75
        if [ $? == 0 ]; then
            echo "Intel" > GPU.txt
            echo " xf86-video-intel " >> packages.inst
        else
            echo "Manual" > GPU.txt
        fi
    fi
fi

if [ $intel != 1 ] && [ $nvidia == 1 ]; then    #Check for Nvidia (Fuck you Nvidia)
    dialog --no-canel --no-collapse --title "Archie installer" --menu "The installer has detected Nvidia graphics! GPUs detected:\n\n`gpucheck`\n\nNote: If you're using an oler graphics cart (older than GTX 700 series), you'll wanna choose the 'Nvidia FOSS (Nouveau driver)'" 60 70 4 1 "Use the Nvidia proprietaty driver" 2 "Use the Nvidia FOSS driver (Nouveau)" 3. "Manual configuration"
fi


#Install profile selector

dialog --title "Archie installer" --menu "Select an installation profile" 10 40 5 1 "Desktop" 2 "Minimal" 2> profile.txt
if [ "`cat profile.txt`" == 1 ]; then #Desktop profile
    dialog --title "Archie installer" --menu "Choose a desktop environment" 15 40 10 1 "KDE Plasma" 2 "Gnome" 3 "XFCE" 4 "Qtile" 2> DE.txt
    if [ "`cat DE.txt`" == 1 ]; then
        cat " plasma xorg sddm grub networkmanager neofetch sudo htop nvim dolphin gwenview spectacle konsole ark unzip p7zip "
    fi
fi
if [ "`cat profile.txt`" == 2 ]; then #Minimal profile
    dialog --title "Archie installer" --msgbox "You have chosen to have a minimal installation!\n\nNote: This will not install X or any sort of sound system, just the bare minimum to get a functional system!" 20 70
    echo " grub networkmanager neofetch sudo htop nvim " >> packages.inst
fi



#Select Disk

diskcount=$(lsblk -nd --output NAME | wc -l)
touch disks.txt
lsblk -nd --output NAME,SIZE > disks.txt
disks=$(cat disks.txt | column -t -N "DISK,SIZE")

diskf(){ #1st disk selector
    dialog --no-cancel --no-collapse  --title "Select a DISK:" --inputbox "$disks" $((diskcount + 7)) 40 2> disk.txt
    seldisk=$(cat disk.txt)
    lsblk -nd --output NAME | grep -x $seldisk &> /dev/null

}
diskf
while [ $? != 0 ]; do #1st disk selector error
    dialog --title "Select a Disk" --msgbox "Error: Invalid disk, please enter a valid disk\n\nHINT:The names of the available disks are shown under the DISK column" 10 50
    
    diskf
done

echo "Selected disk is $seldisk" >> instalLog.log

dialog --no-cancel --title "Archie installer" --menu "Selected disk is: /dev/$seldisk\nHow do you wanna partition the disk?" 10 55 5 \ 1 "Automatic partitioning (Recommended)" \ 2 "Manual partitioning" 2> part.txt
part=$(cat part.txt)

#Check if selected disk in using the nvme prefix

echo $seldisk | grep -E "nvme|zram"
if [ $? == 0 ]; then #check if p1 partition abreviation should be used 
    echo "1" >> isnvme.txt
else
    echo "0" >> isnvme.txt
fi
isnvme=$(cat isnvme.txt)

#Begin partitioning BS
if1exit(){
    if [ $? == 1 ]; then #If NO is selected on the delete all data prompt   
        clear
        echo "Aborting..."
        exit 1
    fi
}

if [ $part == 1 ]; then #Automatic partitioning
    if [ $efi == 1 ]; then #If EFI
        dialog --title "Archie installer" --msgbox "You have chosen to Atomatically partition the disks.\n\nHint: The installer has detected that you are on an UEFI system, meaning that at least 2 partitions will have to be created a Root (/) and an EFI (/boot/efi) partition.\n\nPress ENTER to start configuring the selected disk (/dev/$seldisk/)"   15 80
        touch autodisk.txt
        autodisk(){
            #Swap?
            dialog --title "Archie installer" --yesno "Is a swap partition needed?" 5 40
            if [ $? -eq 0 ]; then #If swap is needed
                dialog --no-cancel --title "Archie installer" --inputbox "How much swap is needed?\n\nEnter it as <size>G with no space, where G stands for gigabytes of swap\ne.g: for 3GB of swap, enter 3G\n\nRecommended ammount of swap: (Ram / 2)\n\nWARNING: If too much swap is entered or it's entered incorrectly, the installer won't make any swap partitions\n\n$disksize" 15 80 2> swapsize.txt
                echo "Swap = yes" >> autodisk.txt 
                echo "Swapsize= `cat swapsize.txt`" >> autodisk.txt 
            fi
            if [ $? != 0 ]; then #If swap isn't needed
                echo "Swap = no" >> autodisk.txt
                echo "Swapsize= 0" >> autodisk.txt
                clear
            fi
            #Home?
                dialog --title "Archie installer" --yesno "Does home need to be on a separate partition?" 5 60
            if [ $? == 0 ]; then #Separate home is needed
                echo "Sephome = yes" >> autodisk.txt
                dialog --no-cancel --title "Archie installer" --inputbox "How many % of the disk do you want your /home partition to be?\n\nRecommended: 65%\nMinimum: 10%\nMaximum: 90%" 13 50 2> sephomesize.txt
                sephomesize=$(cat sephomesize.txt)
                while [ $sephomesize -lt 10 ] || [ $sephomesize -gt 90 ]; do
                    dialog --no-cancel --title "Error" --msgbox "Selected amount of space must be between 10% and 90%!\n\nPlease try again..." 10 45
                    dialog --title "Archie installer" --inputbox "How many % of the disk do you want your /home partition to be?\n\nRecommended: 65%\nMinimum: 10%\nMaximum: 90%" 13 50 2> sephomesize.txt
                    sephomesize=$(cat sephomesize.txt)
                done
                m=$(lsblk -ndb --output NAME,SIZE | grep $seldisk | sed 's/^.* \([^ ]*\)$/\1/' | sed 's/[^0-9.]*//g'); p=$(echo $(( m / 1048576 ))); acchomesize=$(echo $((p*sephomesize/100))) #fuck me, this... wtf is this (converting percents of the disk to an actual size)
               
            fi
            if [ $? != 0 ]; then #Separate home is not needed
                clear
            fi
            #fdisk partition
            rm yes.txt
            touch fdiskconfig.sh
            echo "cat << E0F | fdisk /dev/$seldisk" >> fdiskconfig.sh; echo "g" >> fdiskconfig.sh #Begin fdisk script and set a partition label
            echo "n" >> fdiskconfig.sh; echo "1" >> fdiskconfig.sh; echo "" >> fdiskconfig.sh; echo +300M >> fdiskconfig.sh; echo "t" >> fdiskconfig.sh; echo "1" >> fdiskconfig.sh #Create EFI partition
            cat autodisk.txt | grep -x "Swap = yes"
            if [ $? == 0 ]; then #Swap creation script
                echo -e "n\n3\n\n+`cat swapsize.txt`\nt\n\n19" >> fdiskconfig.sh 
            fi
            cat autodisk.txt | grep -x "Sephome = yes"
            if [ $? == 0 ]; then #Separate home creation script
                echo -e "n\n4\n\n+`echo $acchomesize`M" >> fdiskconfig.sh 
            fi
            echo -e "n\n\n\n" >> fdiskconfig.sh #Create a root partition with the rest of the space
            cp fdiskconfig.sh fdiskconfigshow.sh
            echo -e "p\nE0F" >> fdiskconfigshow.sh
            chmod +x fdiskconfigshow.sh
            dialog --no-collapse --title "Archie installer" --yesno "The following changes will be done to the disk (/dev/$seldisk):\n\nBefore:\n`fdisk -l /dev/$seldisk | grep "/dev" | sed 1d | column -t`\n\nAfter:\n`bash fdiskconfigshow.sh | grep "/dev/$seldisk" | sed 1d | column -t `\n\nIs that OK?\n\nWARNING: Selecting <yes> here WILL DELETE ALL THE DATA ON THE SELECTED DISK!"  25 70 #show changes that are going to be made
            
        } 
        autodisk
        while [ $? != 0 ]; do #If no is selected on the previous prompt
            rm fdiskconfig.sh fdiskconfigshow.sh autodisk.txt 
            dialog --yes-label "OK" --no-label "Exit" --title "Archie installer" --yesno "Select OK and hit ENTER to configure the partitions again or EXIT to exit without making changes..." 10 45
            if [ $? == 1 ]; then
                clear
                echo "Aborting..."
                exit 1
            fi
            rm yes.txt
            autodisk
        done
        dialog --title "Wait..." --infobox "Applying changes to disk..." 10 35
        wipefs -a /dev/$seldisk &> installLog.log  #Wipe disk and apply changes 
        echo -e "w\nE0F" >> fdiskconfig.sh 
        chmod +x fdiskconfig.sh 
        bash fdiskconfig.sh &> /dev/null
        fdisk -l /dev/$seldisk | grep -s "/dev/$seldisk" | sed 1d &> partitions.txt

        if [ $isnvme == 1 ]; then #check if p1 abreviation should be used
            mkfs.fat -F32 "/dev/`echo $seldisk`p1" &> installLog.log #Format EFI
            mkfs.ext4 "/dev/`echo $seldisk`p2" &> installLog.log #Format root
            mkswap "/dev/`echo $seldisk`p3" &> installLog.log    #Make swap
            mkfs.ext4 "/dev/`echo $seldisk`p4" &> installLog.log #Format home
          
            mount "/dev/`echo $seldisk`p2" /mnt &> installLog.log   #Mount Root
            mkdir -p /mnt/boot/efi &> installLog.log
            mount "/dev/`echo $seldisk`p1" /mnt/boot/efi &> installLog.log #Mount EFI
            swapon "/dev/`echo $seldisk`p3"    #Swapon
            mkdir /mnt/home &> installLog.log
            mount "/dev/`echo $seldisk`p4" /mnt/home &> installLog.log #mount home
            

        fi
        if [ $isnvme == 0 ]; then #check if p1 abreviation should be used
            mkfs.fat -F32 "/dev/`echo $seldisk`1" &> installLog.log #Format EFI
            mkfs.ext4 "/dev/`echo $seldisk`2" &> installLog.log #Format root
            mkswap "/dev/`echo $seldisk`3" &> installLog.log    #Make swap
            mkfs.ext4 "/dev/`echo $seldisk`4" &> installLog.log #Format home
        
           
            mount "/dev/`echo $seldisk`2" /mnt &> installLog.log   #Mount Root
            mkdir -p /mnt/boot/efi &> installLog.log
            mount "/dev/`echo $seldisk`1" /mnt/boot/efi &> installLog.log #Mount EFI
            swapon "/dev/`echo $seldisk`3"    #Swapon
            mkdir /mnt/home &> installLog.log
            mount "/dev/`echo $seldisk`4" /mnt/home &> installLog.log #mount home
        fi
    fi
    if [ $efi == 0 ]; then #If BIOS
        dialog --title "Archie installer" --msgbox "You have chosen to Atomatically partition the disks.\n\nHint: The installer has detected that you are on an BIOS/Legacy system, meaning that at least 1 partition will have to be created a Root (/).\n\nPress ENTER to start configuring the selected disk (/dev/$seldisk/)" 15 80
        touch autodisk.txt
        #Swap?
        autodisk(){
            dialog --title "Archie installer" --yesno "Is a swap partition needed?" 5 40
            if [ $? -eq 0 ]; then #If swap is needed
                dialog --no-cancel --title "Archie installer" --inputbox "How much swap is needed?\n\nEnter it as <size>G with no space, where G stands for gigabytes of swap\ne.g: for 3GB of swap, enter 3G\n\nRecommended ammount of swap: (Ram / 2)\n\nWARNING: If too much swap is entered or it's entered incorrectly, the installer won't make any swap partitions\n\n$disksize" 15 80 2> swapsize.txt
                echo "Swap = yes" >> autodisk.txt 
                echo "Swapsize= `cat swapsize.txt`" >> autodisk.txt 
            fi        
            if [ $? != 0 ]; then #If swap isn't needed
                    echo "Swap = no" >> autodisk.txt
                    echo "Swapsize= 0" >> autodisk.txt
                    clear
            fi
             #fdisk partition
            rm yes.txt &> installLog.log
            touch fdiskconfig.sh  
            echo "cat << E0F | fdisk /dev/$seldisk" >> fdiskconfig.sh; echo "o" >> fdiskconfig.sh #Begin fdisk script and set a partition label
            cat autodisk.txt | grep -x "Swap = yes"
            if [ $? == 0 ]; then #Swap creation script
                echo -e "n\np\n2\n\n+`cat swapsize.txt`\ny\nt\n82" >> fdiskconfig.sh 
            fi
            echo -e "n\np\n1\n\n" >> fdiskconfig.sh
            cp fdiskconfig.sh fdiskconfigshow.sh    
            echo -e "p\nE0F" >> fdiskconfigshow.sh
            chmod +x fdiskconfigshow.sh  
            dialog --no-collapse --title "Archie installer" --yesno "The following changes will be done to the disk (/dev/$seldisk):\n\nBefore:\n`fdisk -l /dev/$seldisk | grep "/dev" | sed 1d | column -t`\n\nAfter:\n`bash fdiskconfigshow.sh | grep "/dev/$seldisk" | sed 1d | column -t `\n\nIs that OK?\n\nWARNING: Selecting <yes> here WILL DELETE ALL THE DATA ON THE SELECTED DISK!"  25 75 #show changes that are going to be made
        }
        autodisk
        while [ $? != 0 ]; do #If no is selected on the previous prompt
            rm fdiskconfig.sh fdiskconfigshow.sh autodisk.txt 
            dialog --yes-label "OK" --no-label "Exit" --title "Archie installer" --yesno "Select OK and hit ENTER to configure the partitions again or EXIT to exit without making changes..." 10 45
            if [ $? == 1 ]; then
                clear
                echo "Aborting..."
                exit 1
            fi
            rm yes.txt
            autodisk
        done
        dialog --title "Wait..." --infobox "Applying changes to disk..." 10 35
        wipefs -a /dev/$seldisk &> installLog.log  #Wipe disk and apply changes 
        echo -e "w\nE0F" >> fdiskconfig.sh 
        chmod +x fdiskconfig.sh 
        bash fdiskconfig.sh &> /dev/null
        fdisk -l /dev/$seldisk | grep -s "/dev/$seldisk" | sed 1d &> partitions.txt
        mkfs.ext4 "/dev/`echo $seldisk`1" &> installLog.log #Format root (root is 1st partition here)
        mkswap "/dev/`echo $seldisk`2" &> installLog.log    #Make swap (swap is 2nd partition here)
        mount "/dev/`echo $seldisk`1" /mnt &> installLog.log   #Mount Root
        swapon "/dev/`echo $seldisk`2"    #Swapon
        
    fi

fi
if [ $part == 2 ]; then #Manual partitioning
        dialog --title "WARNING" --yesno "Selecting YES here WILL DELETE ALL THE DATA on the selected disk (/dev/$seldisk/)" 10 85
        if1exit
        wipefs -a /dev/$seldisk
    if [ $efi == 1 ]; then #If UEFI
        
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

        mkfs.ext4 "`cat rootpart.txt`" && mkfs.fat -F32 "`cat efipart.txt`" && mount "`cat rootpart.txt`" /mnt && mkdir -p /mnt/boot/efi && mount "`cat efipart.txt`" /mnt/boot/efi
        if [ "`cat swappart.txt`" != "skip" ]; then #check if swap is skipped
            mkswap "`cat swappart.txt`" &&  swapon "`cat swappart.txt`"
        fi
        if [ "`cat homepart.txt`" != skip ]; then #check if home should be on a separate partition
            mkfs.ext4 "`cat homepart.txt`"  && mount "`cat homepart.txt`" /mnt/home
        fi

        #Continue to write shit from here



    fi
    if [ $efi == 0 ]; then #If BIOS
        dialog --title "Archie installer" --msgbox "You have chosen to manually partition the disks.\n\nPress ENTER to start configuring the selected disk (/dev/$seldisk/)"   15 80
        if1exit
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
        #Partition creation BIOS
        dialog --title "Archie installer" --msgbox "Partitions that will be created:\n\nRoot (/): `cat rootpart.txt`\nSwap:`cat swappart.txt`" 10 50
        mkfs.ext4 "`cat rootpart.txt`" && mount "`cat rootpart.txt`" /mnt
        if [ "`cat swappart.txt`" != "skip" ]; then #check if swap is skipped
            mkswap "`cat swappart.txt`" &&  swapon "`cat swappart.txt`"
        fi
        #Continue to write shit from here

        
    fi
fi

#NOTES: Add a cancel feature to the manual partitioning partition selection


