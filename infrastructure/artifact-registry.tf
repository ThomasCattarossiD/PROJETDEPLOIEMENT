# infra/artifact-registry.tf
resource "google_artifact_registry_repository" "backend" {
  location      = var.region                   # Ex: "europe-west1"
  repository_id = "adspex-backend-repo"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "frontend" {
  location      = var.region
  repository_id = "adspex-frontend-repo"
  format        = "DOCKER"
}