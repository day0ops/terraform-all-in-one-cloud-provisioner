owner = "kasunt"

# ----------------------------------------------------------------------------------
# GKE
# ----------------------------------------------------------------------------------

gke_project        = "field-engineering-apac"
gke_region         = "australia-southeast1"
gke_cluster_name   = "demo"
gke_cluster_count  = 1
gke_node_pool_size = 3
gke_node_type      = "e2-standard-4"

# ----------------------------------------------------------------------------------
# EKS
# ----------------------------------------------------------------------------------

aws_profile        = "default"
eks_region         = "ap-southeast-2"
eks_cluster_name   = "demo"
eks_cluster_count  = 1
eks_node_type      = "t3.medium"
eks_nodes          = 2
eks_min_nodes      = 1
eks_max_nodes      = 3
eks_subnets        = 2

# ----------------------------------------------------------------------------------
# AKS
# ----------------------------------------------------------------------------------

aks_region         = "Australia East"
aks_cluster_name   = "demo"
aks_cluster_count  = 1
aks_node_type      = "Standard_D2_v2"
aks_nodes          = 2
# aks_enable_nodes_auto_scaling = false
# aks_min_nodes                 = null
# aks_max_nodes                 = null
# aks_managed_identities        = []
# aks_restrict_workstation_access = true
# Will need to provide the service principal below
aks_service_principal = null

# ----------------------------------------------------------------------------------
# Common
# ----------------------------------------------------------------------------------

kubernetes_version = "1.34"
