#!/bin/bash
set -e
set -u
set -o pipefail
IFS=$'\n\t'

mkdir -p /home/"$USER_NAME"/.ssh
chmod 0700 /home/"$USER_NAME"/.ssh
wget -O /home/"$USER_NAME"/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub
chmod 0600 /home/"$USER_NAME"/.ssh/authorized_keys
