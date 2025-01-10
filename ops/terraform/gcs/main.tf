terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_id}-terraform-state"
  location      = var.region
  force_destroy = false  # Protection contre la suppression accidentelle

  # Activation du versionning pour garder l'historique des états
  versioning {
    enabled = true
  }

  # Activation de l'accès uniforme pour la sécurité
  uniform_bucket_level_access = true
}