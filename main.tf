terraform {
  required_version = ">= 1.0"

  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "text-summarizer"
}

variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "service_name" {
  description = "Service name"
  type        = string
}

variable "node_pool_name" {
  description = "Name of the primary node in the node pool"
  type        = string
  default     = "primary-node-pool"
}

variable "machine_type" {
  description = "Type of the machine"
  type        = string
  default     = "e2-medium"
}

### 2. Configuración de proveedores
provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

### 3. Recursos de infraestructura en GCP (GKE)
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  lifecycle {
    ignore_changes = [
      node_pool,
      master_auth,
    ]
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = var.node_pool_name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  lifecycle {
    ignore_changes = [node_count]
  }

  node_config {
    preemptible  = true
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

### 4. Fuentes de datos (Data Sources)
data "google_container_cluster" "gke_cluster" {
  name     = google_container_cluster.primary.name
  location = var.region

  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.primary_nodes,
  ]
}

### 5. Configuración del proveedor de Kubernetes
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
}

### 6. Recursos de Kubernetes
resource "kubernetes_service" "service" {
  metadata {
    name = var.service_name
    labels = {
      app = var.app_name
    }
  }
  spec {
    selector = {
      app = var.app_name
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8000
    }
    type = "LoadBalancer"
  }

  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.primary_nodes,
  ]

  lifecycle {
    ignore_changes = [metadata, spec]
  }
}
