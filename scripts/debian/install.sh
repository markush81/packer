#!/bin/bash
set -e
set -u
set -o pipefail
IFS=$'\n\t'

IS_VMWARE=${VMWARE:-0}
IS_PARALLELS=${PARALLELS:-0}

sudo apt-get update -y

if [[ ${IS_PARALLELS} == 1 ]]; then
  mkdir -p /tmp/parallels;
  sudo mount -o loop /home/"$USER_NAME"/prl-tools-lin-arm.iso /tmp/parallels;

  sudo /tmp/parallels/install --install-unattended-with-deps --progress
  sudo umount /tmp/parallels;
  rm -rf /tmp/parallels;
  rm -f /home/"$USER_NAME"/*.iso;
fi

if [[ ${IS_VMWARE} == 1 ]]; then
  sudo apt-get install open-vm-tools
fi

sudo apt-get install curl apt-transport-https gpg openssl net-tools unzip -y

sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get clean -y
sudo apt-get autoclean -y
sudo apt-get autoremove -y

sudo dd if=/dev/zero of=/EMPTY bs=1M || true
sudo rm -f /EMPTY

if [[ ${IS_VMWARE} == 1 ]]; then
  sync
fi

cat /dev/null >~/.bash_history
sudo passwd -l "$USER_NAME"
sudo passwd -d "$USER_NAME"
sudo usermod -L "$USER_NAME"

if [[ ${IS_VMWARE} == 1 ]]; then
  sudo vmware-toolbox-cmd disk shrink /
fi
