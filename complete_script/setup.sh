#!/bin/sh
# Author: Huajie Zhang, Rongcong Xu
# Company: Beijing Infervision Inc.
# Date: July 1st, 2017

# If you want to install additional packages, please add package names to the corresponding lists.
NVIDIA_PACKAGES="nvidia-384 nvidia-docker2 libcudnn5 cuda-8-0"
DEV_TOOLS="gdisk git htop tmux vim encfs openssh-server nodejs aeskulap mysql-workbench mongodb-org docker-ce=17.12.0~ce-0~ubuntu"
PYTHON_PACKAGES="python-dev python-pip python-opencv python-mysqldb ipython"
COMMON_PACKAGES="sublime-text google-chrome-stable sogoupinyin"
EXTRA_PACKAGES="libgdcm-tools"

LIST_OF_APT_PACKAGES="$NVIDIA_PACKAGES $DEV_TOOLS $PYTHON_PACKAGES $COMMON_PACKAGES $EXTRA_PACKAGES"
LIST_OF_PIP_PACKAGES="mxnet-cu80 scipy easydict dicom imutils cython scikit-image redis pymssql xlwt xlrd"

set -ex

echo "Install curl"
sudo apt-get update && sudo apt-get install -y curl

echo "INSTALLING STEP 1"
echo "Add gpgkey"
curl https://mirrors.infervision.com/configs/$(lsb_release -c -s)/gpgkey | sudo apt-key add -

echo "INSTALLING STEP 2"
echo "add mirrors"

# Install Nodejs V6.0x for CT VIEW frontend application
curl http://mirrors.infervision.com/configs/$(lsb_release -c -s)/node6.list | sudo tee /etc/apt/sources.list.d/node6.list

# Install chrome
curl http://mirrors.infervision.com/configs/$(lsb_release -c -s)/chrome.list | sudo tee /etc/apt/sources.list.d/google-chrome.list

# Install cuda
curl http://mirrors.infervision.com/configs/$(lsb_release -c -s)/cuda.list | sudo tee /etc/apt/sources.list.d/cuda.list

# Install cudnn
curl http://mirrors.infervision.com/configs/$(lsb_release -c -s)/cudnn.list | sudo tee /etc/apt/sources.list.d/cudnn.list

# Install nvidia-docker
curl http://mirrors.infervision.com/configs/$(lsb_release -c -s)/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install docker-ce
curl http://mirrors.infervision.com/configs/$(lsb_release -c -s)/docker-ce.list | sudo tee /etc/apt/sources.list.d/docker-ce.list

# Install python 2.7.14
curl --fail http://mirrors.infervision.com/configs/$(lsb_release -c -s)/python2.list | sudo tee /etc/apt/sources.list.d/python2.list

# Install ubuntukylin
curl http://mirrors.infervision.com/configs/$(lsb_release -c -s)/ubuntukylin.list | sudo tee /etc/apt/sources.list.d/sogoupinyin.list

# Install sublime
curl http://mirrors.infervision.com/configs/$(lsb_release -c -s)/sublime.list | sudo tee /etc/apt/sources.list.d/sublime.list

# Install mongodb
curl http://mirrors.infervision.com/configs/$(lsb_release -c -s)/mongodb-3.6.list | sudo tee /etc/apt/sources.list.d/mongodb-3.6.list

# Hold docker-ce
echo "docker-ce hold" | sudo dpkg --set-selections

echo "INSTALLING STEP 3"

sudo apt-get update


echo "Installing APT packages..."
sudo -H apt-get install --force-yes -y $LIST_OF_APT_PACKAGES || exit 1

echo "Upgrading PIP..."
sudo -H pip install --upgrade pip

echo "Add user to docker group"
getent passwd 1000  | cut -d ':' -f 1 | xargs -I % sudo  adduser % docker

# Install chrome
curl http://mirrors.infervision.com/configs/$(lsb_release -c -s)/chrome.list | sudo tee /etc/apt/sources.list.d/google-chrome.list

# Install ubuntukylin
curl http://mirrors.infervision.com/configs/$(lsb_release -c -s)/ubuntukylin.list | sudo tee /etc/apt/sources.list.d/sogoupinyin.list

echo "Install docker compose"
sudo curl -L https://repos.infervision.com/repository/raw/compose/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

echo 'export PATH="/usr/local/cuda-8.0/bin:$PATH"' | sudo tee /etc/profile.d/cuda.sh

echo "INSTALLING STEP 4"
echo "Upgrading pip..."
printf "[global]\ntrusted-host = repos.infervision.com\nindex-url = https://repos.infervision.com/repository/pypi/simple" | sudo tee /etc/pip.conf
sudo -H pip install -U pip -i https://repos.infervision.com/repository/pypi/simple || exit 1

# 安装python依赖包
echo "Installing PYTHON packages..."
sudo -H pip install -I -i https://repos.infervision.com/repository/pypi/simple $LIST_OF_PIP_PACKAGES || exit 1

# mxnet-cu80 package includes older version numpy which conficts with our model
echo "Upgrading numpy package..."
sudo -H pip install --upgrade -i https://repos.infervision.com/repository/pypi/simple numpy || exit 1

#Set hostname
echo "tx-deepocean" | sudo tee /etc/hostname
echo "127.0.0.1 tx-deepocean" | sudo tee -a /etc/hosts

echo "Shut down the ufw(firewall) and disabled it on system startup"
sudo ufw disable || exit 0

