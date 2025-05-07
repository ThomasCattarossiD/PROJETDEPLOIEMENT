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

# Création des repositories Artifact Registry
resource "google_artifact_registry_repository" "frontend" {
  location      = var.region
  repository_id = "adspex-frontend-repo"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "backend" {
  location      = var.region
  repository_id = "adspex-backend-repo"
  format        = "DOCKER"
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