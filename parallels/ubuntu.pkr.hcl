variable "user_name" {
  type    = string
  default = "vagrant"
}

variable "user_pwd" {
  type    = string
  default = "vagrant"
}

variable "user_pwd_encrypted" {
  type    = string
  default = "$6$wLi1bWS5NKrh/mBL$tDuWzn5MhwxYBqOHfBt4/tbJVXt0P/INuccgx/xzIaDjkagKvDTjC3.P457wpyUY07OFkTCH21cQV.mo4Ucvf0"
}

packer {
  required_plugins {
    parallels = {
      version = ">= 1.1.0"
      source  = "github.com/Parallels/parallels"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

source "parallels-iso" "ubuntu" {
  iso_url                = "https://cdimage.ubuntu.com/releases/23.10/release/ubuntu-23.10-live-server-arm64.iso"
  iso_checksum           = "sha256:5ea4c792a0cc5462a975d2f253182e9678cc70172ebd444d730f2c4fd7678e43"
  ssh_username           = "${var.user_name}"
  ssh_password           = "${var.user_pwd}"
  ssh_timeout            = "10m"
  ssh_handshake_attempts = 100000000 #unlimited, cause if ssh is started to early it fails.
  shutdown_command       = "echo '${var.user_pwd}' | sudo -S shutdown -P now"
  guest_os_type          = "ubuntu"
  http_content = {
    "/meta-data" = file("../http/ubuntu/meta-data")
    "/user-data" = templatefile("../http/ubuntu/user-data-parallels.pkrtpl.hcl", { user_name = var.user_name, user_pwd = var.user_pwd_encrypted })
  }
  boot_command = [
    "c",
    "linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
    "<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]
  memory                 = 2048
  cpus                   = 2
  disk_size              = 20480
  vm_name                = "Ubuntu 23.10 (arm64)"
  output_directory       = "ubuntu"
  parallels_tools_mode   = "attach"
  parallels_tools_flavor = "lin-arm"
}

build {
  sources = ["sources.parallels-iso.ubuntu"]

  provisioner "shell" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for Cloud-Init...'; sleep 1; done"]
  }

  post-processor "vagrant" {
    compression_level              = 9
    vagrantfile_template_generated = true
  }
}