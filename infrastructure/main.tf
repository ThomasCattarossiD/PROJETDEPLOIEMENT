provider "google" {
  project = "votre-projet-gcp"
  region  = "europe-west1"
}

resource "google_sql_database_instance" "main" {
  name             = "campaign-db-instance"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-f1-micro"
  }
}

resource "google_kubernetes_cluster" "main" {
  name     = "campaign-cluster"
  location = "europe-west1-b"

  remove_default_node_pool = true
  initial_node_count       = 1

  node_pool {
    name       = "default-pool"
    node_count = 1

    node_config {
      machine_type = "e2-micro"
    }
  }
}