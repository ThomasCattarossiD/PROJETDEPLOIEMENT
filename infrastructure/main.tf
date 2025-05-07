provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "europe-west1"
}

# Cluster GKE (optionnel)
resource "google_container_cluster" "adspex_cluster" {
  name     = "adspex-cluster"
  location = var.region

  initial_node_count = 1
  node_config {
    machine_type = "e2-medium"
  }
}

output "artifact_registry_frontend" {
  value = google_artifact_registry_repository.frontend.name
}

output "artifact_registry_backend" {
  value = google_artifact_registry_repository.backend.name
}