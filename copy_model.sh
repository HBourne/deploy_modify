#!/bin/bash

echo "Copying models..."
cp model/9channel/*.params ~/

echo "Copying test data..."
cp -r test_data_dicom ~/Downloads

echo "Copying duplicates..."
cp -r Install /home/tx-deepocean/Documents

echo "Copying necessary scripts..."
# cp yubikey_deploy.sh ~/Desktop
# cp partition.sh ~/Desktop
# cp make_dir.sh ~/Desktop
# cp examine_firmware.sh ~/Desktop
cp complete_script/* ~/Desktop

echo "Copying model configs..."
cp model/9channel/class* ~/Desktop
cp model/9channel/dlserver.env ~/Desktop

echo "Start git clone..."
cd ~/Desktop
git clone http://101.200.204.36/tx_product_frontline/tx-product-machine-setup-wiki.git -b omni
