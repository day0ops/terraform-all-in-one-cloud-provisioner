module "defaults" {
  source = "../../modules/defaults"
}

# ----------------------------------------------------------------------------------
# EKS IPv6 clusters
# ----------------------------------------------------------------------------------

module "eks_ipv6" {
  source = "../../modules/eks-ipv6"
  count  = var.eks_ipv6_cluster_count

  owner   = var.owner
  team    = var.team
  purpose = var.purpose

  region                          = var.eks_ipv6_region
  max_availability_zones          = var.max_availability_zones
  kubernetes_version              = coalesce(var.kubernetes_version, module.defaults.kubernetes_version)
  allow_istio_mutation_webhook_sg = true
  ec2_ssh_key                     = var.ec2_ssh_key
  create_cni_ipv6_iam_policy      = var.create_cni_ipv6_iam_policy
  enable_dns64                    = var.enable_dns64
  nodes                           = var.eks_ipv6_nodes
  min_nodes                       = var.eks_ipv6_min_nodes
  max_nodes                       = var.eks_ipv6_max_nodes
  node_type                       = var.eks_ipv6_node_type

  enable_bastion_access     = var.enable_bastion && count.index == 0
  bastion_security_group_id = var.enable_bastion && count.index == 0 ? module.bastion[0].bastion_security_group_id : null

  tags = merge(var.extra_tags, {
    "managed-by" = "terraform"
  })
}

# ----------------------------------------------------------------------------------
# Bastion host – attaches to the first cluster's VPC
# ----------------------------------------------------------------------------------

module "bastion" {
  source = "../../modules/bastion"
  count  = var.enable_bastion ? 1 : 0

  enable                     = var.enable_bastion
  owner                      = var.owner
  prefix_name                = try(format("%v-bastion", var.owner), "bastion")
  bastion_ssh_key            = var.ec2_ssh_key
  vpc_id                     = module.eks_ipv6[0].vpc_id
  elb_subnets                = module.eks_ipv6[0].public_subnets
  auto_scaling_group_subnets = module.eks_ipv6[0].public_subnets

  tags = merge(var.extra_tags, {
    "owner"      = var.owner
    "managed-by" = "terraform"
  })
}

# ----------------------------------------------------------------------------------
# Transit Gateway – full IPv6 mesh between all clusters
# ----------------------------------------------------------------------------------

locals {
  create_tgw = var.eks_ipv6_cluster_count > 1

  cluster_pairs = local.create_tgw ? [
    for pair in setproduct(range(var.eks_ipv6_cluster_count), range(var.eks_ipv6_cluster_count))
    : pair if pair[0] != pair[1]
  ] : []

  route_entries = local.create_tgw ? flatten([
    for pair in local.cluster_pairs : [
      for rt_id in module.eks_ipv6[pair[0]].private_route_table_ids : {
        key            = "${pair[0]}-${pair[1]}-${rt_id}"
        route_table_id = rt_id
        dest_cidr      = module.eks_ipv6[pair[1]].vpc_ipv6_cidr_block
      }
    ]
  ]) : []
}

module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.10.0"
  count   = local.create_tgw ? 1 : 0

  name = format("%v-tgw", var.owner)

  enable_auto_accept_shared_attachments = false
  enable_multicast_support              = false
  enable_dns_support                    = true
  share_tgw                             = false

  tags = merge(var.extra_tags, {
    "owner"      = var.owner
    "managed-by" = "terraform"
  })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "eks_ipv6" {
  count = local.create_tgw ? var.eks_ipv6_cluster_count : 0

  transit_gateway_id = module.tgw[0].ec2_transit_gateway_id
  subnet_ids         = module.eks_ipv6[count.index].private_subnets
  vpc_id             = module.eks_ipv6[count.index].vpc_id

  dns_support            = "enable"
  ipv6_support           = "enable"
  appliance_mode_support = "disable"

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  depends_on = [module.eks_ipv6]

  tags = merge(var.extra_tags, {
    Name         = "eks-ipv6-${count.index + 1}-tgw-attachment"
    "owner"      = var.owner
    "managed-by" = "terraform"
  })
}

resource "aws_route" "eks_ipv6_cross_cluster" {
  for_each = { for entry in local.route_entries : entry.key => entry }

  route_table_id              = each.value.route_table_id
  destination_ipv6_cidr_block = each.value.dest_cidr
  transit_gateway_id          = module.tgw[0].ec2_transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.eks_ipv6]
}
