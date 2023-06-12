variable "user_name" {
  type    = string
  default = "vagrant"
}

variable "user_pwd" {
  type    = string
  default = "vagrant"
}

packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

source "vmware-iso" "debian" {
  iso_url           = "https://cdimage.debian.org/debian-cd/12.0.0/arm64/iso-cd/debian-12.0.0-arm64-netinst.iso"
  iso_checksum      = "sha256:e455263fb33c71ebf8396a823cdc15ca75786efd2e86172c067a97b1fa9924a5"
  ssh_username      = "${var.user_name}"
  ssh_password      = "${var.user_pwd}"
  ssh_timeout       = "5m"
  shutdown_command  = "echo '${var.user_pwd}' | sudo -S shutdown -P now"
  guest_os_type     = "arm-debian12-64"
  disk_adapter_type = "nvme"
  version           = 20
  http_directory    = "http/debian"
  boot_command = [
    "c",
    "linux /install.a64/vmlinuz",
    " auto-install/enable=true",
    " debconf/priority=critical",
    " netcfg/get_hostname=debian-12",
    " netcfg/get_domain=",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg --- quiet",
    "<enter>",
    "initrd /install.a64/initrd.gz",
    "<enter>",
    "boot",
    "<enter><wait>"
  ]
  usb = true
  vmx_data = {
    "usb_xhci.present" = "true"
  }
  memory               = 2048
  cpus                 = 2
  disk_size            = 20480
  vm_name              = "Debian 12.0 (arm64)"
  network_adapter_type = "e1000e"
  output_directory     = "debian"
}

build {
  sources = ["sources.vmware-iso.debian"]

  provisioner "shell" {
    execute_command = "echo '${var.user_pwd}' | {{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    inline          = ["echo '%sudo    ALL=(ALL)  NOPASSWD:ALL' >> /etc/sudoers"]
  }

  provisioner "shell" {
    inline = [
      "mkdir -p /home/${var.user_name}/.ssh",
      "chmod 0700 /home/${var.user_name}/.ssh",
      "wget -O /home/${var.user_name}/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub",
      "chmod 0600 /home/${var.user_name}/.ssh/authorized_keys"
    ]
  }

  provisioner "shell" {
    script = "scripts/debian/disable-ipv6.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install curl apt-transport-https open-vm-tools gpg openssl net-tools unzip -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get dist-upgrade -y",
      "sudo apt-get clean -y",
      "sudo apt-get autoclean -y",
      "sudo apt-get autoremove -y",
      "sudo dd if=/dev/zero of=/EMPTY bs=1M || true",
      "sudo rm -f /EMPTY",
      "sync",
      "cat /dev/null > ~/.bash_history",
      "sudo passwd -l ${var.user_name}",
      "sudo passwd -d ${var.user_name}",
      "sudo usermod -L ${var.user_name}",
      "sudo vmware-toolbox-cmd disk shrink /"
    ]
  }
}