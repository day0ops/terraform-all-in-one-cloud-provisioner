locals {
  count = var.enable_eks ? 1 : 0
}

# Random identifier for cluster name suffix
resource "random_id" "eks_cluster_name_suffix" {
  count = local.count

  byte_length = 6
}

# Get the current workstation public IP
data "http" "workstation_public_ip" {
  count = local.count

  url = "http://ipv4.icanhazip.com"
}

locals {
  provider_type           = "eks"
  cluster_name            = try(join("-", [format("%v-%v-%v", var.owner, var.eks_cluster_name, random_id.eks_cluster_name_suffix.0.hex), var.eks_cluster_index]), "")
  kubeconfig_context      = try(format("%v-%v", local.provider_type, local.cluster_name), "")
  k8s_version             = try(var.kubernetes_version, "")
  workstation_public_cidr = try("${chomp(data.http.workstation_public_ip.0.response_body)}/32", "")
  tags = merge(
    {
      "provider"   = local.provider_type
      "cluster"    = local.cluster_name
      "created-by" = var.owner
      "team"       = var.team
      "purpose"    = var.purpose
      "managed-by" = "terraform"
    },
    var.extra_tags
  )
  asg_tags = flatten([
    for key in keys(local.tags) : {
      key                 = key
      value               = local.tags[key]
      propagate_at_launch = "true"
  }])
  service_cidr = aws_eks_cluster.eks_master.0.kubernetes_network_config.0.service_ipv4_cidr
  nodeadm_user_data = <<-EOT
#!/bin/bash
set -ex

# Ensure cloud-init is up to date
dnf update -y cloud-init

cat <<'NODECONFIG' > /tmp/nodeadm-config.yaml
---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${local.cluster_name}
    apiServerEndpoint: ${aws_eks_cluster.eks_master.0.endpoint}
    certificateAuthority: ${aws_eks_cluster.eks_master.0.certificate_authority.0.data}
    cidr: ${local.service_cidr}
NODECONFIG

/usr/bin/nodeadm init --config-source file:///tmp/nodeadm-config.yaml
EOT
}

data "aws_availability_zones" "eks_available_zones" {
  count = local.count
}

data "aws_region" "eks_region" {
  count = local.count
}

# EKS optimized AMI via SSM (works for any EKS-supported version; uses AL2023 recommended AMI)
data "aws_ssm_parameter" "eks_worker_ami" {
  count = local.count

  name = "/aws/service/eks/optimized-ami/${local.k8s_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

resource "aws_vpc" "eks_vpc" {
  count = local.count

  cidr_block = var.eks_cidr_block

  tags = merge(
    {
      Name                                          = local.cluster_name
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    },
    local.tags
  )
}

resource "aws_subnet" "eks_public_subnet" {
  count = var.enable_eks ? var.eks_subnets : 0

  availability_zone = data.aws_availability_zones.eks_available_zones.0.names[count.index]
  cidr_block        = cidrsubnet(var.eks_cidr_block, 8, count.index)
  vpc_id            = aws_vpc.eks_vpc.0.id

  tags = merge(
    {
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    },
    {
      "kubernetes.io/role/elb" = "1"
    },
    local.tags
  )
}

resource "aws_internet_gateway" "eks_igw" {
  count = local.count

  vpc_id = aws_vpc.eks_vpc.0.id

  tags = local.tags
}

resource "aws_route_table" "eks_rt" {
  count = local.count

  vpc_id = aws_vpc.eks_vpc.0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.0.id
  }

  tags = local.tags
}

resource "aws_route_table_association" "eks_rt_assoc" {
  count = var.enable_eks ? var.eks_subnets : 0

  subnet_id      = aws_subnet.eks_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.eks_rt.0.id
}

resource "aws_iam_role" "eks_master_iam_role" {
  count = local.count

  name               = format("%v-master-role", local.cluster_name)
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "eks_master_cluster_policy" {
  count = local.count

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_iam_role.0.name
}

resource "aws_iam_role_policy_attachment" "eks_master_service_policy" {
  count = local.count

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_master_iam_role.0.name
}

# Master Security Group
resource "aws_security_group" "eks_master_sec_group" {
  count = local.count

  name        = format("%v-master-sg", local.cluster_name)
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks_vpc.0.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group_rule" "eks_master_sec_group_rule_allow_workstation" {
  count = local.count

  cidr_blocks       = [local.workstation_public_cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_master_sec_group.0.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "eks_master" {
  count = local.count

  name     = local.cluster_name
  role_arn = aws_iam_role.eks_master_iam_role.0.arn
  version  = local.k8s_version

  vpc_config {
    security_group_ids = [aws_security_group.eks_master_sec_group.0.id]
    subnet_ids         = flatten([aws_subnet.eks_public_subnet[*].id])
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_master_cluster_policy,
    aws_iam_role_policy_attachment.eks_master_service_policy
  ]
}

resource "aws_iam_role" "eks_worker_iam_role" {
  count = local.count

  name               = format("%v-worker-role", local.cluster_name)
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  count = local.count

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_iam_role.0.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_cni_policy" {
  count = local.count

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_iam_role.0.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_ec2_container_readonly" {
  count = local.count

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_iam_role.0.name
}

resource "aws_iam_instance_profile" "eks_worker_instance_profile" {
  count = local.count

  name = format("%v-instance-profile", local.cluster_name)
  role = aws_iam_role.eks_worker_iam_role.0.name
}

resource "aws_security_group" "eks_worker_sec_group" {
  count = local.count

  name        = format("%v-worker-sg", local.cluster_name)
  description = "Security group for all worker nodes in the cluster"
  vpc_id      = aws_vpc.eks_vpc.0.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    },
    local.tags
  )
}

resource "aws_security_group_rule" "eks_worker_sec_group_rule_allow_self" {
  count                    = local.count
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_worker_sec_group.0.id
  source_security_group_id = aws_security_group.eks_worker_sec_group.0.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_worker_sec_group_rule_allow_control_plane_to_pods" {
  count                    = local.count
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker_sec_group.0.id
  source_security_group_id = aws_security_group.eks_master_sec_group.0.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_worker_sec_group_rule_allow_pods_to_k8_api" {
  count                    = local.count
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_master_sec_group.0.id
  source_security_group_id = aws_security_group.eks_worker_sec_group.0.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_launch_template" "eks_worker_lt" {
  count = local.count

  name_prefix   = local.cluster_name
  image_id      = data.aws_ssm_parameter.eks_worker_ami.0.value
  instance_type = var.eks_node_type
  user_data     = base64encode(local.nodeadm_user_data)

  iam_instance_profile {
    name = aws_iam_instance_profile.eks_worker_instance_profile.0.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.eks_worker_sec_group[0].id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name                                          = local.cluster_name
        "kubernetes.io/cluster/${local.cluster_name}" = "owned"
      },
      local.tags
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks_worker_asg" {
  count = local.count

  name             = local.cluster_name
  desired_capacity = var.eks_nodes
  max_size         = var.eks_max_nodes
  min_size         = var.eks_min_nodes
  vpc_zone_identifier = aws_subnet.eks_public_subnet.*.id

  launch_template {
    id      = aws_launch_template.eks_worker_lt.0.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = concat(
      local.asg_tags,
      [
        {
          key                 = "Name"
          value               = local.cluster_name
          propagate_at_launch = true
        },
        {
          key                 = "kubernetes.io/cluster/${local.cluster_name}"
          value               = "owned"
          propagate_at_launch = true
        }
      ]
    )
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  aws_auth_rendered = local.count > 0 ? templatefile("${path.module}/files/aws-auth-template.yaml.tpl", {
    rolearn = aws_iam_role.eks_worker_iam_role.0.arn
  }) : ""
  kubeconfig_rendered = local.count > 0 ? templatefile("${path.module}/files/kubeconfig-template.tpl", {
    context                = local.kubeconfig_context
    endpoint               = aws_eks_cluster.eks_master.0.endpoint
    cluster_ca_certificate = aws_eks_cluster.eks_master.0.certificate_authority.0.data
    cluster_name           = local.cluster_name
    region                 = var.eks_region
    profile                = var.aws_profile
  }) : ""
}

resource "local_file" "aws_auth_tpl_renderer" {
  count = local.count

  content  = local.aws_auth_rendered
  filename = "${path.module}/output/aws-auth-${var.eks_cluster_index}.yaml"

  depends_on = [aws_eks_cluster.eks_master]
}

resource "local_file" "kubeconfig_tpl_renderer" {
  count = local.count

  content  = local.kubeconfig_rendered
  filename = "${path.module}/output/kubeconfig-eks-${var.eks_cluster_index}"

  depends_on = [local_file.aws_auth_tpl_renderer]
}

resource "null_resource" "aws_auth_configmap_apply" {
  count = local.count

  provisioner "local-exec" {
    # Retry loop: EKS API server may not be ready immediately after cluster creation
    command = <<-EOT
      for i in 1 2 3 4 5 6; do
        kubectl apply --validate=false -f ${path.module}/output/aws-auth-${var.eks_cluster_index}.yaml && exit 0
        echo "Attempt $i failed, waiting for EKS API server... (retry in 10s)"
        sleep 10
      done
      echo "Failed to apply aws-auth ConfigMap after 6 attempts"
      exit 1
    EOT
    environment = {
      KUBECONFIG  = "${path.module}/output/kubeconfig-eks-${var.eks_cluster_index}"
      AWS_PROFILE = var.aws_profile
    }
  }

  depends_on = [local_file.aws_auth_tpl_renderer, local_file.kubeconfig_tpl_renderer]
}

# -- Route53

locals {
  dns_enabled      = var.enable_dns && local.count > 0
  dns_child_domain = local.dns_enabled ? "${var.dns_child_zone_name}.${var.dns_parent_domain}" : ""
}

resource "aws_route53_zone" "child" {
  count         = local.dns_enabled ? 1 : 0
  name          = local.dns_child_domain
  force_destroy = true
  tags          = local.tags
}

resource "aws_route53_record" "child_ns" {
  count   = local.dns_enabled ? 1 : 0
  zone_id = var.dns_parent_zone_id
  name    = local.dns_child_domain
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.child[0].name_servers
}

resource "aws_iam_policy" "eks_worker_route53_policy" {
  count = local.dns_enabled ? 1 : 0
  name  = format("%v-route53-policy", local.cluster_name)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["route53:ChangeResourceRecordSets"]
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:GetChange",
          "route53:ListHostedZones",
          "route53:ListHostedZonesByName",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]
        Resource = "*"
      }
    ]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "eks_worker_route53_policy" {
  count      = local.dns_enabled ? 1 : 0
  policy_arn = aws_iam_policy.eks_worker_route53_policy[0].arn
  role       = aws_iam_role.eks_worker_iam_role[0].name
}

# -- OIDC Provider

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  count           = local.count
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = aws_eks_cluster.eks_master[0].identity[0].oidc[0].issuer
  tags            = local.tags
  depends_on      = [aws_eks_cluster.eks_master]
}

# -- EBS CSI Driver

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  count = local.count
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks_oidc_provider[0].arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc_provider[0].url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc_provider[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver_role" {
  count              = local.count
  name               = format("%v-ebs-csi-driver-role", local.cluster_name)
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role[0].json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  count      = local.count
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver_role[0].name
}

resource "aws_eks_addon" "ebs_csi_driver" {
  count                       = local.count
  cluster_name                = aws_eks_cluster.eks_master[0].name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.ebs_csi_driver_role[0].arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags                        = local.tags
  depends_on                  = [aws_iam_role_policy_attachment.ebs_csi_driver_policy]
}

# -- GP3 Storage Class

resource "null_resource" "gp3_storage_class" {
  count = local.count

  provisioner "local-exec" {
    command = <<-EOT
      kubectl patch storageclass gp2 \
        -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}' || true
      kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  encrypted: "true"
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
EOF
    EOT
    environment = {
      KUBECONFIG  = "${path.module}/output/kubeconfig-eks-${var.eks_cluster_index}"
      AWS_PROFILE = var.aws_profile
    }
  }

  depends_on = [aws_eks_addon.ebs_csi_driver, null_resource.aws_auth_configmap_apply]
}
