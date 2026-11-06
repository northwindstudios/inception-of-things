packer {
  required_version = ">= 1.10.0"

  required_plugins {
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.7.0-amd64-netinst.iso"
}

variable "iso_sha256" {
  type    = string
  default = "a7ef94ac2fb9a7fec454552abd629b7cc9d5155c886165a45649f5ce6167e355"
}

source "virtualbox-iso" "debian" {
  vm_name       = "debian-13"
  guest_os_type = "Debian_64"
  headless      = true

  iso_url      = var.iso_url
  iso_checksum = "sha256:${var.iso_sha256}"

  cpus                 = 2
  memory               = 1024
  disk_size            = 10240
  hard_drive_interface = "sata"
  iso_interface        = "sata"
  guest_additions_mode = "disable"

  http_directory = "${path.root}/http"
  boot_wait      = "10s"
  boot_command = [
    "<esc><wait>",
    "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg hostname=debian domain=local<enter>",
  ]

  ssh_username     = "vagrant"
  ssh_password     = "vagrant"
  ssh_timeout      = "60m"
  shutdown_command = "sudo systemctl poweroff"

  output_directory = "${path.root}/output"
}

build {
  sources = ["source.virtualbox-iso.debian"]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | sudo -S bash '{{ .Path }}'"
    script          = "${path.root}/provision.sh"
  }

  post-processor "vagrant" {
    output            = "${path.root}/../../boxes/debian-13-virtualbox.box"
    compression_level = 9
  }
}
