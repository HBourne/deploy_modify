#!/bin/bash

# Determining whether to activate encryption script or not
while [[ "$encrypt" != "y" && "$encrypt" != "n" ]]
do
	read -p "Encrypt model with yubikey? [y/n] " encrypt
	if [[ "$encrypt" != "y" && "$encrypt" != "n" ]]; then
	echo -e "\nPlease enter [y/n]!"
	fi
done

# Go on depending on the input
if [ $encrypt = y ]; then
	git clone http://101.200.204.36/root/tx-param-encryption-v1.git
	if [ $? = 128 ]; then
		echo "Problems occurred while cloning. Please remove the downloaded project and retry!" && exit 0
	fi

	# Install dependencies
	echo "Installing dependencies..."
	sed -i 's/pip install/sudo -H pip install/g' tx-param-encryption-v1/install.sh
    cd ./tx-param-encryption-v1
	sudo bash install.sh
    cd -

	# Yubikey interactive part
	echo -e "\nPlease insert yubikey."

	# Check if inserted
	while [[ "$insert" != "y" ]]
	do
		read -p "Inserted yubikey or not? [y/n] " insert
		if [[ "$insert" != "y" ]]; then
		echo -e "\nPlease enter [y/n]!"
		fi
	done

	# Reset yubikey
	echo -e "\nReseting yubikey"
	sudo ./tx-param-encryption-v1/bin/yubikey-reset

	# Check if re-inserted
	while [[ "$reinsert" != "y" ]]
	do
		echo "Please reinsert yubikey!"
		read -p "Re-inserted yubikey or not? [y/n] " reinsert
		if [[ "$reinsert" != "y" ]]; then
		echo -e "\nPlease enter [y/n]!"
		fi
	done

	# Start to create key pairs
	echo -e "\nCreating key pairs on yubikey..."

	# Get servername
	while true; do
		read -p "Please enter the name of the server (it should be of the form tx-SER****): " servername1
		if [[ $servername1 =~ ^tx-SER ]]; then
			read -p "Please enter the name of the server again: " servername2
			if [ "$servername1" = "$servername2" ]; then
				break
			else
				echo -e "\nPlease make sure the input is consistent. Try again."
			fi
		else
			echo -e "\nBad input! Please try again."
		fi
	done

	# Generate key
	sudo ./tx-param-encryption-v1/bin/infervision-keygen-card-v1 $servername1
	gpg --import "$servername1".private.asc

	# Encrypt models
	echo -e "\nEncrypting model..."
	for model in `ls ~ | grep .params`; do
		sudo ./tx-param-encryption-v1/bin/infervision-encrypt-v1 $servername1 ~/"$model"
		echo "$model" encrypted!
	done
	cp ./*.bin ~/Infervision/omni-deploy/model/
	cp ./*.bin ~/Infervision/tx_dlserver/model/
	sudo rm ./*.bin
	sudo rm ~/*.params
	mv ./tx-SER* /media/tx-deepocean/KINGSTON/key/

	# Modifying dlserver.py
	echo "Modifying dlserver.py..."
	sed -i "6a from infervision_decrypt_v1 import apply_patch\napply_patch(mx.nd, \"$servername1\")" ~/Infervision/tx_dlserver/dlserver.py

	# Modifying omni-deploy docker env...
	echo "Modifying omni-deploy docker env..."
	sed -i "s/tx-SER.*/$servername1/g" ~/Infervision/omni-deploy/docker-compose.yml
	sed -i "s/tx-SER.*/$servername1\"/g" ~/Infervision/omni-deploy/.env

else
	echo -e "\nExiting encryption script........"
fi
