# Zone DNS
resource "google_dns_managed_zone" "app_zone" {
  name        = "app-zone"
  dns_name    = "${var.domain_name}."
  description = "Zone DNS pour l'application"
}

# Enregistrement DNS pour le load balancer
resource "google_dns_record_set" "app" {
  name         = "app.${google_dns_managed_zone.app_zone.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.app_zone.name
  rrdatas      = [google_compute_forwarding_rule.default.ip_address]
}