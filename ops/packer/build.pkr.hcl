packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1.0"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1.0"
    }
  }
}

variable "project_id" {
  type = string
}

source "googlecompute" "app" {
  project_id          = var.project_id
  zone               = "europe-west1-b"
  source_image_family = "debian-11"
  ssh_username       = "packer"
  image_name         = "app-image-{{timestamp}}"
  image_description  = "Application image"
  machine_type       = "e2-medium"
  
  # Scopes corrects pour GCP
  service_account_email = "234413656647-compute@developer.gserviceaccount.com"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/devstorage.read_write",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/compute"
  ]
}

build {
  sources = ["source.googlecompute.app"]

  provisioner "ansible" {
    playbook_file = "./ops/ansible/playbook.yml"
    user = "packer"
    use_proxy = false
    extra_arguments = [
      "-e", "ansible_remote_tmp=/tmp/ansible",
      "--ssh-extra-args", "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    ]
  }
}