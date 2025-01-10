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