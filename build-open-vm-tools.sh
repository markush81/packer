#!/bin/bash

# open-vm-tools
#
# https://www.virten.net/2020/10/vmware-tools-for-debian-10-arm64-on-esxi-arm/
# https://kb.vmware.com/s/article/74650
# https://github.com/vmware/photon/tree/master/SPECS/open-vm-tools
#

sudo apt-get install -t bullseye-backports -y curl fuse libglib2.0-0 libxmlsec1 libxmlsec1-openssl libdrm-dev libcurl4-openssl-dev automake make gobjc++ libtool pkg-config libudev-dev libfuse-dev libmspack-dev libglib2.0-dev libpam0g-dev libssl-dev libxml2-dev libxmlsec1-dev libx11-dev libxext-dev libxinerama-dev libxi-dev libxrender-dev libxrandr-dev libxtst-dev libgdk-pixbuf2.0-dev libgtk-3-dev libgtkmm-3.0-dev

cd /tmp || exit
wget -c https://github.com/vmware/open-vm-tools/archive/refs/tags/stable-12.2.0.tar.gz -O - | tar -xz --strip-components 1
cd open-vm-tools || exit

autoreconf -i
./configure --disable-dependency-tracking --enable-containerinfo=no
make
sudo make install
sudo ldconfig

cat << EOF | sudo tee -a /etc/systemd/system/vgauthd.service
[Unit]
Description=VGAuth Service for open-vm-tools
Documentation=http://github.com/vmware/open-vm-tools
ConditionVirtualization=vmware
PartOf=vmtoolsd.service

[Service]
ExecStart=/usr/local/bin/VGAuthService -s
TimeoutStopSec=5

[Install]
RequiredBy=vmtoolsd.service
EOF

sudo systemctl enable vgauthd.service
sudo systemctl start vgauthd.service

cat << EOF | sudo tee -a /etc/systemd/system/vmtoolsd.service
[Unit]
Description=Service for virtual machines hosted on VMware
Documentation=http://github.com/vmware/open-vm-tools
ConditionVirtualization=vmware
Requires=vgauthd.service
DefaultDependencies=no
Before=cloud-init-local.service
After=dbus.service

[Service]
ExecStart=/usr/local/bin/vmtoolsd
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
Also=vgauthd.service
EOF

sudo systemctl enable vmtoolsd.service
sudo systemctl start vmtoolsd.service

cat << EOF | sudo tee -a /etc/systemd/system/mnt-hgfs.mount
[Unit]
Description=VMware mount for hgfs
DefaultDependencies=no
Before=umount.target
ConditionVirtualization=vmware
After=sys-fs-fuse-connections.mount

[Mount]
What=vmhgfs-fuse
Where=/mnt/hgfs
Type=fuse
Options=default_permissions,allow_other

[Install]
WantedBy=multi-user.target
EOF

cat << EOF | sudo tee -a /etc/modules-load.d/open-vm-tools.conf
fuse
EOF

sudo systemctl enable mnt-hgfs.mount
sudo systemctl start mnt-hgfs.mount

# open-vm-tools expects in different path, then it builds
#
#[2023-04-09T07:39:18.764Z] [ message] [vix] [1119] ToolsDaemonTcloReceiveVixCommand: command 62, additionalError = 17
#[2023-04-09T07:39:18.764Z] [   debug] [vmsvc] [1119] RpcIn: sending 961 bytes
#[2023-04-09T07:39:18.776Z] [   debug] [vmsvc] [1119] RpcIn: received 42 bytes, content:"Vix_1_Mount_Volumes "3" "x" "vmhgfs" "0" #"
#[2023-04-09T07:39:18.776Z] [   debug] [vmsvc] [1119] Executing sync command: /usr/bin/vmhgfs-fuse --enabled
#[2023-04-09T07:39:18.778Z] [   debug] [vmsvc] [1119] Done waiting for process: 1162 (failure)
#[2023-04-09T07:39:18.778Z] [   debug] [vmsvc] [1119] Executed sync command: /usr/bin/vmhgfs-fuse --enabled -> 0 (127)
#[2023-04-09T07:39:18.778Z] [ message] [vix] [1119] ToolsDaemonTcloMountHGFS: vmhgfs-fuse -> 127: not supported on this kernel version
#[2023-04-09T07:39:18.779Z] [   debug] [vix] [1119] ToolsDaemonTcloMountHGFS: Mounting: /usr/bin/mount -t vmhgfs .host:/ /mnt/hgfs
#[2023-04-09T07:39:18.779Z] [   debug] [vmsvc] [1119] Executing sync command: /usr/bin/mount -t vmhgfs .host:/ /mnt/hgfs
#[2023-04-09T07:39:18.781Z] [   debug] [vmsvc] [1119] Done waiting for process: 1163 (failure)
#[2023-04-09T07:39:18.781Z] [ warning] [vix] [1119] ToolsDaemonTcloMountHGFS: ERROR: no vmhgfs mount
#[2023-04-09T07:39:18.781Z] [ message] [vix] [1119] ToolsDaemonTcloMountHGFS: returning 20050 17
sudo ln -sf /usr/local/bin/vmhgfs-fuse /usr/bin/vmhgfs-fuse

# Cleanup
sudo apt-get remove -y libdrm-dev libcurl4-openssl-dev automake make gobjc++ libtool pkg-config libudev-dev libfuse-dev libmspack-dev libglib2.0-dev libpam0g-dev libssl-dev libxml2-dev libxmlsec1-dev libx11-dev libxext-dev libxinerama-dev libxi-dev libxrender-dev libxrandr-dev libxtst-dev libgdk-pixbuf2.0-dev libgtk-3-dev libgtkmm-3.0-dev

rm -rf /tmp/open-vm-tools
