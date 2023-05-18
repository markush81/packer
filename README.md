# Packer

## Debian 11

- arm64 (therefore apple silicon compatible)
- open-vm-tools
- VMware Fusion Player 13 compatible
- backport kernel (6.1.x.y)

```bash
packer init debian.pkr.hcl
packer build debian.pkr.hcl
cd debian
cp ../metadata.json .
tar cvzf debian-11-arm64.box ./*
vagrant box add --name debian-11-arm64 debian-11-arm64.box --force
cd ..
```

Vagrantfile (>=2.3.5)

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "debian-11-arm64"
end
```

----

## Ubuntu 23.04

- arm64 (therefore apple silicon compatible)
- open-vm-tools
- VMware Fusion Player 13 compatible

```bash
packer init ubuntu.pkr.hcl
packer build ubuntu.pkr.hcl
cd ubuntu
cp ../metadata.json .
tar cvzf ubuntu-23.04-arm64.box ./*
vagrant box add --name ubuntu-23.04-arm64 ubuntu-23.04-arm64.box --force
cd ..
```

Vagrantfile (>=2.3.5)

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu-23.04-arm64"
end
```