owner = "kasunt"

enable_gke         = false
gke_project        = "field-engineering-apac"
gke_cluster_count  = 1
gke_region         = "australia-southeast1"
gke_cluster_name   = "gp"
gke_node_pool_size = 3
gke_node_type      = "e2-standard-4"

enable_eks             = true
aws_profile            = "default"
eks_region             = "ap-northeast-1"
eks_cluster_name       = "gp"
eks_cluster_count      = 3
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
