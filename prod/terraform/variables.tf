variable "project_id" {
  description = "ID du projet GCP"
  type        = string
}

variable "region" {
  description = "Région GCP"
  type        = string
  default     = "europe-west9"
}

variable "app_image" {
  description = "Image de l'application"
  type        = string
}

variable "machine_type" {
  description = "Type de machine pour les instances"
  type        = string
  default     = "e2-medium"
}