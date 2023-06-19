#!/bin/bash
set -e
set -u
set -o pipefail
IFS=$'\n\t'

cat <<EOF | sudo tee -a /etc/sysctl.d/disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
EOF
