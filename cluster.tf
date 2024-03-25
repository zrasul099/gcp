resource "google_service_account" "default" {
  account_id   = var.service_account_id
  display_name = var.display_name
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.location_tf

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = var.node_count

  node_config {
    disk_size_gb = var.cluster_disk_size
}
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.cluster_node
  location   = var.location_tf
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    preemptible  = true
    machine_type = var.machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}