# Packer

## VMware Fusion

### Debian 12.0

- arm64 (apple silicon compatible)
- open-vm-tools
- ipv6 disabled
- VMware Fusion Player 13

```bash
cd vmware
packer init debian.pkr.hcl
packer build debian.pkr.hcl
vagrant box add --name debian-12-arm64 packer_debian_vmware.box --force
cd ..
```

Vagrantfile (>=2.3.5)

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "debian-12-arm64"
end
```

```bash
vagrant up --provider vmware_desktop
```

----

### Ubuntu 23.04

- arm64 (apple silicon compatible)
- open-vm-tools
- VMware Fusion Player 13

```bash
cd vmware
packer init ubuntu.pkr.hcl
packer build ubuntu.pkr.hcl
vagrant box add --name ubuntu-23.04-arm64 packer_ubuntu_vmware.box --force
cd ..
```

Vagrantfile (>=2.3.5)

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu-23.04-arm64"
end
```

```bash
vagrant up --provider vmware_desktop
```

## Parallels

### Debian 12.0

- arm64 (apple silicon compatible)
- ipv6 disabled
- Parallels Desktop 18 Pro
- Parallels Tools

```bash
cd parallels
packer init debian.pkr.hcl
packer build debian.pkr.hcl
vagrant box add --name debian-12-arm64 packer_debian_parallels.box --force
cd ..
```

:warning: in case you get the message `Failed creating Parallels driver: Parallels Virtualization SDK is not installed`, use `PYTHONPATH=/Library/Frameworks/ParallelsVirtualizationSDK.framework/Versions/10/Libraries/Python/3.7 packer build debian.pkr.hcl`.

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "debian-12-arm64"
end
```

```bash
vagrant up --provider parallels
```