 #!/usr/bin/env bash
dsk=$(cat Temp_Files/userdisk.txt)
function spacer {
echo "-------------------------------------------------------------------"
}

touch Temp_Files/sfdisk.txt
wipefs -a $dsk
echo "label: DOS" >> Temp_Files/sfdisk.txt
echo ",4G, S" >> Temp_Files/sfdisk.txt
echo ",, L" >> Temp_Files/sfdisk.txt
sfdisk $dsk < Temp_Files/sfdisk.txt
rm Temp_Files/sfdisk.txt