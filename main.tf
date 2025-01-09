provider "google" {
  project     = "cesi-ops"
  region      = "europe-west1"
}

resource "null_resource" "build_image" {
  provisioner "local-exec" {
    command = "packer build -var 'artifact_url=https://europe-west1-go.pkg.dev/cesi-ops/depotartifcat/}' ./packer_template.json"
  }
}
resource "google_compute_image" "custom_image" {
  name = "custom-app-image"
  source_image = "packer-output-image"
  family = "custom-app-family"
}
resource "google_storage_bucket" "terraform_states" {
  name          = "terraform-states-bucket"
  location      = "europe-west1"
  force_destroy = false
  versioning {
    enabled = true
  }
}
resource "google_storage_bucket_iam_binding" "binding" {
  bucket   = google_storage_bucket.terraform_states.name
  role     = "roles/storage.admin"
  members  = ["serviceAccount:terraform@project-id.iam.gserviceaccount.com"]
}
