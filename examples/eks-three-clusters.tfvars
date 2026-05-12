owner = "kasunt"

# ----------------------------------------------------------------------------------
# EKS
# ----------------------------------------------------------------------------------

aws_profile        = "default"
eks_region         = "ap-northeast-1"
eks_cluster_name   = "demo"
eks_cluster_count  = 3
eks_node_type      = "t3.medium"
eks_nodes          = 2
eks_min_nodes      = 1
eks_max_nodes      = 3
eks_subnets        = 2
kubernetes_version = "1.34"

# ----------------------------------------------------------------------------------
# DNS (optional - Route53 child zone)
# ----------------------------------------------------------------------------------

# enable_dns          = true
# dns_parent_zone_id  = "Z0408115XSU33JVY62D3"
# dns_parent_domain   = "kasunt.apac.fe.solo.io"
# dns_child_zone_name = "demo"
