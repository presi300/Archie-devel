cat << E0F | fdisk /dev/zram0
g
n
1

+300M
t
1
n



p
E0F
