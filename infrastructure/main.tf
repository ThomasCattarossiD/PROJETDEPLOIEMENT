# main.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Réseau VPC dédié
resource "google_compute_network" "vpc" {
  name                    = "adtech-vpc"
  auto_create_subnetworks = false
}

# Sous-réseau sécurisé
resource "google_compute_subnetwork" "subnet" {
  name          = "adtech-subnet"
  ip_cidr_range = "10.10.0.0/20"
  region        = var.region
  network       = google_compute_network.vpc.id
  
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "172.16.0.0/14"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "192.168.0.0/20"
  }
}

# Règles de firewall minimales
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # À restreindre en prod !
}

# Cluster GKE en mode Autopilot (managed)
resource "google_container_cluster" "main" {
  name     = "adtech-cluster"
  location = var.zone

  # Configuration réseau avancée
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  # Configuration IP secondaires pour GKE
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Activation de Autopilot (recommandé)
  enable_autopilot = true

  # Maintenance window quotidienne
  maintenance_policy {
    recurring_window {
      start_time = "03:00"
      end_time   = "05:00"
      recurrence = "FREQ=DAILY"
    }
  }

  # Canal de release stable avec mises à jour auto
  release_channel {
    channel = "STABLE"
  }

  # Configuration de sécurité
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Protection contre la suppression accidentelle
  deletion_protection = true
}

# Variables
variable "project_id" {
  description = "ID du projet GCP"
  type        = string
  default     = "durable-limiter-459106-k2"
}

variable "region" {
  description = "Région GCP (ex: europe-west1)"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone GCP (ex: europe-west1-b)"
  type        = string
  default     = "europe-west1-b"
}

# Outputs
output "cluster_name" {
  value = google_container_cluster.main.name
}

output "cluster_endpoint" {
  value = google_container_cluster.main.endpoint
}

output "network_self_link" {
  value = google_compute_network.vpc.self_link
}