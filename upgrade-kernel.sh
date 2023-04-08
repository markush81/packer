#!/bin/sh

# fixes Unknown ioctl 1976

cat << EOF | sudo tee -a /etc/apt/sources.list
deb http://deb.debian.org/debian bullseye-backports main contrib non-free
deb-src http://deb.debian.org/debian bullseye-backports main contrib non-free
EOF

sudo apt-get update

sudo apt-get -t bullseye-backports upgrade -y
sudo apt-get -t bullseye-backports dist-upgrade -y

sudo apt-get clean -y
sudo apt-get autoclean -y
sudo apt-get autoremove -y

sudo reboot
