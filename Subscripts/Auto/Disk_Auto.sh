 #!/usr/bin/env bash
dsk=$(cat Temp_Files/userdisk.txt)
function spacer {
echo "-------------------------------------------------------------------"
}

sudo dmesg | grep "EFI v"
if [ $? -eq 0 ]; then #if EFI
    clear
    echo "What changes will be made:"
    spacer
    cat Temp_Files/userdisk.txt | grep "nvme" 
    if [ $? -eq 0 ]; then
        echo $dsk"p1 - 300M EFI partition"
        echo $dsk"p2 - 4G SWAP partition"
        echo $dsk"p3 - The rest of the space. Root partition"
    else
        echo $dsk"1 - 300M EFI partition"
        echo $dsk"2 - 4G SWAP partition"
        echo $dsk"3 - The rest of the space. Root partition"
    fi

    echo ""
    echo "Do you want to proceed?"
    echo ""
    echo "--WARNING--"
    echo THIS WILL ERASE ALL DATA ON THE $dsk DISK
    spacer
    read -p "Press ENTER to proceed or do ctrl+C to exit without changes..."
    bash Subscripts/Auto/DiskFormat/uefi.sh
else    #If not EFI
    clear
    echo "What changes will be made:"
    spacer
    echo $dsk"1 - 4G SWAP partition"
    echo $dsk"2 - The rest of the space. Root partition"
    echo ""
    echo "Do you want to proceed?"
    echo ""
    echo "--WARNING--"
    echo THIS WILL ERASE ALL DATA ON THE $dsk DISK
    spacer
    read -p "Press ENTER to proceed or do ctrl+C to exit without changes..."
    bash Subscripts/Auto/DiskFormat/mbr.sh
fi
