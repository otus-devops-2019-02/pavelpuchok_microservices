terraform {
  required_version = "~> 0.12.3"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  version = "~> 2.10"
}

variable "project_id" {
  type        = "string"
  description = "GCP project id"
}

variable "zone" {
  type        = "string"
  default     = "europe-west1-b"
  description = "GCP Zone"
}

variable "region" {
  type        = "string"
  default     = "europe-west1"
  description = "GCP Region"
}

variable "node_count" {
  type        = number
  default     = 2
  description = "Cluster node counts"
}

variable "node_machine_type" {
  type        = "string"
  default     = "g1-small"
  description = "GCP Machine type for cluster nodes"
}

variable "node_disk_size_gb" {
  type        = "string"
  default     = 20
  description = "Cluster node disk size"
}

resource "google_container_cluster" "reddit" {
  name     = "reddit"
  location = var.zone

  master_auth {
    # disable basic auth
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    kubernetes_dashboard {
      disabled = false
    }
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "reddit_node_pool" {
  name       = "reddit-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.reddit.name
  node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size_gb
  }
}

resource "google_compute_firewall" "outside_door" {
  name    = "k8s-outside-door"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
}
