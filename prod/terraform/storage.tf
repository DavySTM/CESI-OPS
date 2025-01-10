# Bucket pour les fichiers statiques
resource "google_storage_bucket" "static" {
  name          = "${var.project_id}-static"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = true

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# IAM pour rendre le bucket public
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.static.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}