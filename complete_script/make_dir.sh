#!/bin/bash

echo "Creating folders..."
sudo chown -R $USER /media/$USER/
mkdir -p /media/$USER/Data/DICOMS/DR    || exit 1
mkdir -p /media/$USER/Data/DICOMS/CT    || exit 1
mkdir -p /media/$USER/Data/output/DR    || exit 1
mkdir -p /media/$USER/Data/output/CT    || exit 1
mkdir -p /media/$USER/Data/json/CT      || exit 1
mkdir -p /media/$USER/Data/json/DR      || exit 1