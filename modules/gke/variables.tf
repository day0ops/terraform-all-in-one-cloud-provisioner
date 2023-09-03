variable "enable_gke" {
  description = "Enable / Disable Google GKE (Default: `false`)"
  type        = bool
  default     = false
}

variable "gke_project" {
  description = "GCP Project ID for GKE"
  type        = string

  validation {
    condition     = can(length(var.gke_project) > 0)
    error_message = "GKE project ID of the cluster must be provided."
  }
}

variable "gke_region" {
  description = "GCP region for GKE (Default: `australia-southeast1`, Ref: https://cloud.google.com/compute/docs/regions-zones)"
  type        = string
  default     = "australia-southeast1"
}

variable "gke_cluster_name" {
  description = "GKE cluster name"
  type        = string

  validation {
    condition     = can(length(var.gke_cluster_name) > 0)
    error_message = "GKE cluster name must be provided."
  }
}

variable "gke_cluster_index" {
  description = "GKE cluster index when multiple clusters are required"
  type        = string
}

variable "enable_gke_regional_cluster" {
  description = "Create regional GKE cluster instead of zonal (Default: `false`)"
  type        = bool
  default     = false
}

variable "gke_node_pool_size" {
  description = "GKE Kubernetes worker nodes (Default: `3`)"
  type        = number
  default     = 3
}

variable "enable_gke_preemptible" {
  description = "Use GKE preemptible nodes (Default: `false`)"
  type        = bool
  default     = false
}

variable "gke_node_type" {
  description = "GKE node instance type (Default: `n1-standard-2`, Ref: https://cloud.google.com/compute/docs/general-purpose-machines)"
  type        = string
  default     = "n1-standard-2"
}

variable "gke_node_image_type" {
  description = "The image to use for this node (Default: `cos_containerd`, Ref: https://cloud.google.com/kubernetes-engine/docs/concepts/node-images)"
  type        = string
  default     = "cos_containerd"
}

variable "gke_serviceaccount" {
  description = "GCP default service account for GKE"
  type        = string
  default     = "default"
}

variable "gke_serviceaccount_description" {
  description = "The description of the custom service account for GKE"
  type        = string
  default     = ""
}

variable "gke_serviceaccount_roles" {
  description = "Additional roles to be added to the service account for GKE"
  type        = list(string)
  default     = []
}

variable "enable_gke_hpa" {
  description = "Horizontal pod autoscaling for replicate controller to scale the pods (Default: `true`)"
  type        = bool
  default     = true
}

variable "gke_oauth_scopes" {
  description = "GCP OAuth scopes for GKE (Ref: https://www.terraform.io/docs/providers/google/r/container_cluster.html#oauth_scopes)"
  type        = list(string)
  default = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring"
  ]
}

variable "kubernetes_version" {
  description = "Kubernetes version. If not specified the current stable version is used"
  type        = string
  default     = null
}

# -- Tagging and labeling

variable "owner" {
  description = "Name of the maintainer of the GKE cluster"
  type        = string
}

variable "team" {
  description = "Team that maintains the cluster"
  type        = string
}

variable "purpose" {
  description = "Purpose for the cluster"
  type        = string
}

variable "extra_labels" {
  description = "Labels used for the GKE resources"
  type        = map(string)
  default     = {}
}

variable "extra_tags" {
  description = "Tags used for the GKE resources"
  type        = list(string)
  default     = []
}
