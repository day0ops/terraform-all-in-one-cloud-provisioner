owner = "kasunt"

# ----------------------------------------------------------------------------------
# EKS IPv6
# ----------------------------------------------------------------------------------

aws_profile            = "default"
eks_ipv6_region        = "ap-southeast-2"
eks_ipv6_cluster_name  = "demo"
eks_ipv6_cluster_count = 1
eks_ipv6_node_type     = "t3.medium"
eks_ipv6_nodes         = 2
eks_ipv6_min_nodes     = 1
eks_ipv6_max_nodes     = 3
kubernetes_version     = "1.34"

# Only create the CNI IPv6 IAM policy once per AWS account
create_cni_ipv6_iam_policy = false

# Maximum AZs to spread nodes across
max_availability_zones = 2

# Enable DNS64 for IPv4-only destination reachability from IPv6 pods
enable_dns64 = true

# Enable bastion host attached to first cluster VPC
enable_bastion = true

# SSH key for bastion/node access (must exist in the target region)
# ec2_ssh_key = "my-key-pair"
