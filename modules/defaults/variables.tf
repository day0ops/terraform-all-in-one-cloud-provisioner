# Single source of truth for default Kubernetes version used across all environments.
# Change this value to update the default for AKS, EKS, and GKE in every environment.

variable "kubernetes_version" {
  description = "Default Kubernetes version for all cluster types (AKS, EKS, GKE)"
  type        = string
  default     = "1.34"
}
