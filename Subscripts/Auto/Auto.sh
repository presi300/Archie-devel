 #!/usr/bin/env bash
function disk {
    read -p "Select a disk: " dsk
    echo ""
    touch Temp_Files/userdisk.txt
    echo $dsk > Temp_Files/userdisk.txt
    sudo fdisk -l $dsk | grep "Disk /dev/" > Temp_Files/fdiskout.txt
    entcheck=$(cat Temp_Files/fdiskout.txt | grep -c "/dev/") #this doesn't work if you only have 1 disk... but eeeh you only have 1 disk then anyways
    if [ $entcheck -ne 1 ]; then
        sudo pacman -S jaslfkjaf
    else   
        echo "mqn"
    fi

}
function spacer {
echo "-------------------------------------------------------------------"
}


clear
echo "You have chosen the the 'Full Auto' instalation option"
echo
echo "This will automatically install/configure Arch linux to a selected disk"
spacer
echo "Press ENTER to view disks"
read pressenter
sudo fdisk -l | grep "Disk /dev/"

disk #This is really important
while [ $? -ne 0 ]; do
clear
echo "Error: Invalid option, please try again!"
spacer
echo "Press ENTER to view disks"
read pressenter
sudo fdisk -l | grep "Disk /dev/"
spacer
disk
done

clear
echo "Selected disk:"
spacer
cat Temp_Files/fdiskout.txt
echo ""
read -p "Press ENTER to continue"
bash Subscripts/Auto/Disk_Auto.sh
