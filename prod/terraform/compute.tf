# Template d'instance
resource "google_compute_instance_template" "app_template" {
  name        = "app-template"
  description = "Template pour les instances de l'application"

  tags = ["http-server"]

  machine_type = var.machine_type

  disk {
    source_image = var.app_image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.app_subnet.id
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = <<-EOF
      #!/bin/bash
      systemctl start app
      systemctl enable app
    EOF
  }
}

# Groupe d'instances managé
resource "google_compute_instance_group_manager" "app_group" {
  name = "app-mig"

  base_instance_name = "app"
  zone              = "${var.region}-a"

  version {
    instance_template = google_compute_instance_template.app_template.id
  }

  target_size = 2

  named_port {
    name = "http"
    port = 8080
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 300
  }
}

# Health check pour auto-healing
resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  http_health_check {
    request_path = "/health"
    port         = "8080"
  }
}

# Load Balancer régional
resource "google_compute_region_backend_service" "backend" {
  name                  = "app-backend"
  region                = var.region
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"

  backend {
    group = google_compute_instance_group_manager.app_group.instance_group
  }

  health_checks = [google_compute_health_check.autohealing.id]
}

# URL Map
resource "google_compute_region_url_map" "url_map" {
  name            = "app-url-map"
  region          = var.region
  default_service = google_compute_region_backend_service.backend.id
}

# Target HTTP Proxy
resource "google_compute_region_target_http_proxy" "http_proxy" {
  name    = "app-http-proxy"
  region  = var.region
  url_map = google_compute_region_url_map.url_map.id
}

# Forwarding rule
resource "google_compute_forwarding_rule" "default" {
  name                  = "app-forwarding-rule"
  region                = var.region
  port_range           = "80"
  load_balancing_scheme = "INTERNAL_MANAGED"
  network              = google_compute_network.vpc.id
  subnetwork           = google_compute_subnetwork.lb_subnet.id
  target               = google_compute_region_target_http_proxy.http_proxy.id
}