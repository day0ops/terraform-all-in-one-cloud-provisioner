owner = "kasunt"

enable_gke         = false

enable_eks             = true
aws_profile            = "default"
eks_region             = "ap-southeast-1"
eks_cluster_name       = "gp"
eks_cluster_count      = 1
eks_node_type          = "t3.medium"
eks_nodes              = 3
eks_kubernetes_version = "1.24"

enable_aks        = false
aks_region        = "Australia East"
aks_cluster_name  = "gp"
aks_cluster_count = 1
aks_node_type     = "Standard_D2_v2"
aks_nodes         = 2
aks_service_principal = null
