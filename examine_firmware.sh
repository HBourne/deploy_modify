#!/bin/bash
# Check network interface 
echo "Checking network interface info..."
device=`ifconfig -a | grep -2 inet | grep -i ethernet | grep -iv vmnet | awk '{print $1}'`
echo "`echo $device | wc -l` network interfaces found:"
for i in $device; do
    echo $i
done

# Check disk info
echo -e "\nChecking disk info..."
disknum=`lsblk | grep disk | awk '{print $3, $1 , $4}' | grep ^0 | awk '{print $2, $3}' | wc -l`
echo "$disknum disks found:"
for ((i=1;i<=$disknum;i++)); do
    diskinfo="/dev/`lsblk | grep disk | awk '{print $3, $1 , $4}' | grep ^0 | awk '{print $2, $3}' | head -n $i | tail -n 1`"
    echo $diskinfo
done

# Check NVIDIA graphic card
echo -e "\nChecking graphic card info..."
nvidianum=`nvidia-smi | grep GTX | awk '{print $3,$4,$5}' | wc -l`
echo "$nvidianum graphic cards found:"
for ((i=1;i<=$nvidianum;i++)); do
    echo `nvidia-smi | grep GTX | awk '{print $3,$4,$5}' | head -n $i | tail -n 1`
done

