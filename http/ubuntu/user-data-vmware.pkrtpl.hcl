#cloud-config
autoinstall:
  version: 1
  apt:
    geoip: true
  refresh-installer:
    update: true
  source:
    id: ubuntu-server-minimal
    search_drivers: false
  updates: security
  early-commands:
    - sudo systemctl stop ssh
  keyboard:
    layout: de
  storage:
    layout:
      name: lvm
  identity:
    hostname: ubuntu-23_10
    realname: ${user_name}
    username: ${user_name}
    password: ${user_pwd}
  network:
    network:
      version: 2
      ethernets:
        ens160:
          dhcp4: yes
  ssh:
    install-server: true
    allow-pw: true
    authorized-keys:
      # https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub
      - ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
  packages:
    - locales
    - openssh-server
    - open-vm-tools
    - vim
  late-commands:
    - curtin in-target --target=/target -- echo '${user_name}  ALL=(ALL) NOPASSWD:ALL' >> /target/etc/sudoers.d/${user_name}
    - curtin in-target --target=/target -- apt-get update -y
    - curtin in-target --target=/target -- apt-get upgrade -y
    - curtin in-target --target=/target -- apt-get dist-upgrade -y
    - curtin in-target --target=/target -- apt-get clean -y
    - curtin in-target --target=/target -- apt-get autoremove -y
    - curtin in-target --target=/target -- apt-get autoclean -y
    - curtin in-target --target=/target -- dd if=/dev/zero of=/target/EMPTY bs=1M || true
    - curtin in-target --target=/target -- rm -f /target/EMPTY
    - curtin in-target --target=/target -- sync
    - curtin in-target --target=/target -- vmware-toolbox-cmd disk shrinkonly
  user-data:
    disable_root: true
    locale: en_US.UTF-8
    timezone: UTC
    late-commands: []
