
variable "image_name" {
  type    = string
  default = ""
}

variable "machine_type" {
  type    = string
  default = ""
}

variable "network" {
  type    = string
  default = ""
}

variable "project_id" {
  type    = string
  default = ""
}

variable "source_image" {
  type    = string
  default = ""
}

variable "subnetwork" {
  type    = string
  default = ""
}

variable "zone" {
  type    = string
  default = ""
}

source "googlecompute" "build_machine" {
  disable_default_service_account = true
  disk_size                       = "50"
  disk_type                       = "pd-ssd"
  image_name                      = "${var.image_name}"
  machine_type                    = "${var.machine_type}"
  metadata = {
  }
  network        = "${var.network}"
  project_id     = "${var.project_id}"
  source_image   = "${var.source_image}"
  state_timeout  = "10m"
  subnetwork     = "${var.subnetwork}"
  zone           = "${var.zone}"
  ssh_username   = "jenkins"
}

build {
  sources = ["source.googlecompute.build_machine"]

  provisioner "file" {
    sources     = [
      "VMs",
      "Scripts"
    ]
    destination = "~"
  }

  provisioner "shell" {
    inline = [
      "sudo ~/VMs/agents/linux/swarm-agent/install.sh"
    ]
  }

  provisioner "shell" {
    inline = [
      "rm -rf ~/VMs"
    ]
  }
}
