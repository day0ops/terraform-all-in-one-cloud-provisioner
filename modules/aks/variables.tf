variable "enable_aks" {
  description = "Enable / Disable Microsoft AKS (Default: `false`)"
  type        = bool
  default     = false
}

variable "aks_region" {
  description = "Azure region for AKS (Default: `Australia East`, Ref: https://docs.microsoft.com/en-us/azure/aks/availability-zones)"
  type        = string
  default     = "Australia East"
}

variable "aks_cluster_name" {
  description = "AKS cluster name"
  type        = string

  validation {
    condition     = can(length(var.aks_cluster_name) > 0)
    error_message = "AKS cluster name must be provided."
  }
}

variable "aks_cluster_index" {
  description = "AKS cluster index when multiple clusters are required"
  type        = string
}

variable "aks_nodes" {
  description = "AKS worker nodes (e.g. `2`)"
  type        = number
  default     = 2
}

variable "aks_enable_nodes_auto_scaling" {
  description = "Enable autoscaling for AKS worker nodes based on minimum and maximum limits set below (Default: `false`)"
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
  description = "Azure node pool instance type (Default: `Standard_D2_v2`, Ref: https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs)"
  type        = string
  default     = "Standard_D2_v2"
}

variable "aks_availability_zones" {
  description = "To spread the nodes in this node pool across multiple physical locations"
  type        = list(string)
  default     = null
}

variable "aks_vnet_cidr_block" {
  description = "Azure AKS virtual network CIDR block (Default: `192.168.0.0/16`)"
  type        = list(string)
  default     = ["192.168.0.0/16"]
}

variable "aks_vnet_subnet_cidr_block" {
  description = "Azure AKS subnet CIDR block (Default: `10.0.0.0/16`)"
  type        = list(string)
  default     = ["192.168.1.0/24"]
}

variable "aks_service_cidr_block" {
  description = "Azure AKS service CIDR block (Default: `10.0.0.0/16`)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "kubernetes_version" {
  description = "Kubernetes version. If not specified the current stable version is used"
  type        = string
  default     = null
}

variable "worker_node_authentication" {
  description = "Worker node authentication that includes path to the SSH public key (e.g. `~/.ssh/id_rsa.pub`) and username"
  type        = map(string)
  default     = null
}

variable "aks_service_principal" {
  description = "Service principal to connect to AKS cluster"
  type = object({
    object_id     = string
    client_id     = string
    client_secret = string
  })
}

variable "aks_addons" {
  description = "Addons to enable / disable for AKS cluster (Default: Azure policy enabled)"
  type = object({
    log_analytics_workspace_enabled = bool
    oms_agent_workspace_id          = string
    policy                          = bool
  })
  default = {
    log_analytics_workspace_enabled = false
    oms_agent_workspace_id          = null
    policy                          = true
  }
}

variable "aks_managed_identities" {
  description = "List of managed identities where the AKS service principal should have access"
  type        = list(string)
  default     = []
}

variable "aks_diagnostics" {
  description = "Diagnostic settings for those resources such as Log Analytics that support it"
  type = object({
    destination = string
    logs        = list(string)
  })
  default = null
}

variable "aks_automatic_channel_upgrade" {
  description = "The upgrade channel for Kubernetes cluster (Default: `null` - sets to 'none')"
  type        = string
  default     = null
}

variable "aks_restrict_workstation_access" {
  description = "Restrict access to the Kubernetes cluster with the workstation CIDR (Default: `true`)"
  type        = bool
  default     = true
}

# -- Tagging and labeling

variable "owner" {
  description = "Name of the maintainer of the AKS cluster"
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

variable "extra_tags" {
  description = "Tags used for the AKS resources"
  type        = map(string)
  default     = {}
}
