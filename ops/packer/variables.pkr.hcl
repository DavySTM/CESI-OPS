variable "project_id" {
  type = string
  description = "The GCP project ID"
}

variable "zone" {
  type = string
  default = "europe-west9-a"
  description = "The GCP zone for the instance"
}