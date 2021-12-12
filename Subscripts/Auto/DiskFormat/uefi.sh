#!/usr/bin/env bash
dsk=$(cat Temp_Files/userdisk.txt)
function spacer {
echo "-------------------------------------------------------------------"
}

wipefs -a $dsk   
touch Temp_Files/sfdisk.txt
echo "label: GPT" >> Temp_Files/sfdisk.txt
echo ",300M, U"  >> Temp_Files/sfdisk.txt
echo ",4G, S" >> sfdisk.txt
sfdisk $dsk < Temp_Files/sfdisk.txt
rm Temp_Files/sfdisk.txt
