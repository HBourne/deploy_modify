#!/bin/sh

SSD=$(lsblk -b | grep disk | awk '{ print $3,$1,$4 }' | grep '^0' | sort -nk 3 | head -1 | cut -d ' ' -f 2 | sed "s:s:/dev/s:g")
DATA1=$(lsblk -b | grep disk | awk '{ print $3,$1,$4 }' | grep '^0' | sort -nk 3 | head -2 | tail -1 | cut -d ' ' -f 2 | sed "s:s:/dev/s:g")
DATA2=$(lsblk -b | grep disk | awk '{ print $3,$1,$4 }' | grep '^0' | sort -nk 3 | head -3 | tail -1 | cut -d ' ' -f 2 | sed "s:s:/dev/s:g")
DATA3=$(lsblk -b | grep disk | awk '{ print $3,$1,$4 }' | grep '^0' | sort -nk 3 | head -4 | tail -1 | cut -d ' ' -f 2 | sed "s:s:/dev/s:g")

sudo dd if=/dev/zero of=$DATA1 bs=512 count=1

sudo -H gdisk $DATA1 << EOF
o
y
n
 
 
 

w
y
EOF

sudo dd if=/dev/zero of=$DATA2 bs=512 count=1

sudo -H gdisk $DATA2 << EOF
o
y
n
 
 
 

w
y
EOF

sudo dd if=/dev/zero of=$DATA3 bs=512 count=1

sudo -H gdisk $DATA3 << EOF
o
y
n
 
 
 

w
y
EOF

sudo -H pvcreate -ff -y "$DATA1"1 "$DATA2"1 "$DATA3"1
sudo -H vgcreate -y DATA "$DATA1"1
sudo -H vgextend -y DATA "$DATA2"1
sudo -H vgextend -y DATA "$DATA3"1
sudo -H lvcreate -l 100%VG -n DATA DATA
#sudo -H vgchange -a y DATA
#sudo -H lvscan
sudo -H mkdir -p /media/tx-deepocean/Data
sudo -H mkfs.ext4 /dev/mapper/DATA-DATA
sudo -H mount /dev/mapper/DATA-DATA /media/tx-deepocean/Data
grep DATA /etc/fstab || sudo -H echo /dev/mapper/DATA-DATA /media/tx-deepocean/Data ext4 defaults 0 2 | sudo tee -a /etc/fstab
