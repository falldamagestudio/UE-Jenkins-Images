
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

packer {
  required_plugins {
    windows-update = {
      version = "0.12.0"
      source = "github.com/rgl/windows-update"
    }
  }
}

source "googlecompute" "build_machine" {
  communicator                    = "winrm"
  disable_default_service_account = true
  disk_size                       = "50"
  disk_type                       = "pd-ssd"
  image_name                      = "${var.image_name}"
  machine_type                    = "${var.machine_type}"
  metadata = {
    windows-startup-script-cmd = "winrm quickconfig -quiet & net user /add packer_user & net localgroup administrators packer_user /add & winrm set winrm/config/service/auth @{Basic=\"true\"}"
  }
  network        = "${var.network}"
  project_id     = "${var.project_id}"
  source_image   = "${var.source_image}"
  state_timeout  = "10m"
  subnetwork     = "${var.subnetwork}"
  winrm_insecure = true
  winrm_use_ssl  = true
  winrm_username = "packer_user"
  zone           = "${var.zone}"
}

build {
  sources = ["source.googlecompute.build_machine"]

  provisioner "windows-update" {
  }

  provisioner "file" {
    source      = "builder-files"
    destination = "C:\\"
  }

  provisioner "powershell" {
    inline = [ "try { Expand-Archive -Path C:\\builder-files\\builder-files.zip -DestinationPath C:\\ -ErrorAction Stop } catch { Write-Error $_; exit 1 }" ]
  }

  provisioner "powershell" {
    inline = [ "try { & C:\\VMs\\docker-agents\\windows\\ssh-agent\\InstallSoftware.ps1 } catch { Write-Error $_; exit 1 }" ]
  }
  provisioner "powershell" {
    inline = [ "exit (Invoke-Pester -Script C:\\VMs\\docker-agents\\windows\\VerifyInstance.ps1 -PassThru).FailedCount" ]
  }

  provisioner "powershell" {
    inline = [
      "Remove-Item -Force -Recurse C:\\VMs -ErrorAction Stop",
      "Remove-Item -Force -Recurse C:\\builder-files -ErrorAction Stop"
    ]
  }
}
