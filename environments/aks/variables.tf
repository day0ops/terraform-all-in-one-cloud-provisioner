# ----------------------------------------------------------------------------------
# Common
# ----------------------------------------------------------------------------------

variable "owner" {
  description = "Name of the maintainer of the cluster"
  type        = string

  validation {
    condition     = length(var.owner) > 0
    error_message = "Maintainer of the cluster must be provided."
  }
}

variable "team" {
  description = "Team that maintains the cluster"
  type        = string
  default     = "fe-presale"
}

variable "purpose" {
  description = "Purpose for the cluster"
  type        = string
  default     = "pre-sales"
}

variable "kubernetes_version" {
  description = "Override Kubernetes version (default from modules/defaults)"
  type        = string
  default     = null
}

# ----------------------------------------------------------------------------------
# AKS
# ----------------------------------------------------------------------------------

variable "aks_region" {
  description = "Azure region for AKS"
  type        = string
  default     = "Australia East"
}

variable "aks_cluster_count" {
  description = "Number of AKS clusters"
  type        = number
  default     = 1
}

variable "aks_cluster_name" {
  description = "AKS cluster name"
  type        = string
}

variable "aks_nodes" {
  description = "AKS Kubernetes worker nodes"
  type        = number
  default     = 2
}

variable "aks_enable_nodes_auto_scaling" {
  description = "Enable autoscaling for AKS worker nodes"
  type        = bool
  default     = false
}

variable "aks_min_nodes" {
  description = "AKS worker nodes minimum node count"
  type        = number
  default     = null
}

variable "aks_max_nodes" {
  description = "AKS worker nodes maximum node count"
  type        = number
  default     = null
}

variable "aks_node_type" {
  description = "Azure node pool instance type"
  type        = string
  default     = "Standard_D2_v2"
}

variable "aks_service_principal" {
  description = "Service principal to connect to AKS cluster"
  type = object({
    object_id     = string
    client_id     = string
    client_secret = string
  })
}

variable "aks_managed_identities" {
  description = "List of managed identities where the AKS service principal should have access"
  type        = list(string)
  default     = []
}

variable "aks_restrict_workstation_access" {
  description = "Restrict access to the Kubernetes cluster with the workstation CIDR"
  type        = bool
  default     = true
}
