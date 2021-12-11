 #!/usr/bin/env bash
dsk=$(cat /root/Archie/Temp_Files/userdisk.txt)
function spacer {
echo "-------------------------------------------------------------------"
}

touch sfdisk.txt
wipefs -a $dsk
echo "label: DOS" >> sfdisk.txt
echo ",4G, S" >> sfdisk.txt
echo ",, L" >> sfdisk.txt
sfdisk $dsk < sfdisk.txt
