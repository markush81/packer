variable "user_name" {
  type    = string
  default = "vagrant"
}

variable "user_pwd" {
  type    = string
  default = "vagrant"
}

packer {
  required_version = "= 1.11.2"
  required_plugins {
    vmware = {
      version = "= 1.1.0"
      source  = "github.com/hashicorp/vmware"
    }
    vagrant = {
      version = "= 1.1.5"
      source = "github.com/hashicorp/vagrant"
    }
  }
}

source "vmware-iso" "debian" {
  iso_url           = "https://cdimage.debian.org/debian-cd/12.7.0/arm64/iso-cd/debian-12.7.0-arm64-netinst.iso"
  iso_checksum      = "sha256:ff476eeee26162e42111277796cdb7470ff1f1f6203bd9bc4548d211ebf9f931"
  ssh_username      = "${var.user_name}"
  ssh_password      = "${var.user_pwd}"
  ssh_timeout       = "5m"
  shutdown_command  = "echo '${var.user_pwd}' | sudo -S shutdown -P now"
  guest_os_type     = "arm-debian12-64"
  disk_adapter_type = "nvme"
  version           = 20
  http_directory    = "../http/debian"
  boot_command = [
    "c",
    "linux /install.a64/vmlinuz",
    " auto-install/enable=true",
    " debconf/priority=critical",
    " netcfg/hostname=debian-12",
    " netcfg/get_domain=",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg --- quiet",
    "<enter>",
    "initrd /install.a64/initrd.gz",
    "<enter>",
    "boot",
    "<enter><wait>"
  ]
  memory               = 2048
  cpus                 = 2
  disk_size            = 20480
  vm_name              = "Debian 12.0 (arm64)"
  network_adapter_type = "e1000e"
  output_directory     = "debian"
  usb                  = true
  vmx_data = {
    "usb_xhci.present" = "true"
  }
}

build {
  sources = ["sources.vmware-iso.debian"]

  provisioner "shell" {
    execute_command = "echo '${var.user_pwd}' | {{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    inline          = ["echo '%sudo    ALL=(ALL)  NOPASSWD:ALL' >> /etc/sudoers"]
  }

  provisioner "shell" {
    environment_vars = [
      "USER_NAME=${var.user_name}",
      "VMWARE=1"
    ]
    scripts = [
      "../scripts/debian/create-user.sh",
      "../scripts/debian/disable-ipv6.sh",
      "../scripts/debian/install.sh"
    ]
  }

  post-processor "vagrant" {
    compression_level              = 9
    vagrantfile_template_generated = true
  }
}