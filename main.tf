# -----------------------------------------------------------------------------
# DATA
# -----------------------------------------------------------------------------
data "aws_default_tags" "vars" {}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.this.version}/amazon-linux-2/recommended/release_version"
}

data "aws_ami" "al2023" {
  most_recent = "true"
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

# -----------------------------------------------------------------------------
# LOCALS
# -----------------------------------------------------------------------------
locals {
  prefix = "${data.aws_default_tags.vars.tags.Environment}-${data.aws_default_tags.vars.tags.Project}"
}

# -----------------------------------------------------------------------------
# EKS Cluster
# -----------------------------------------------------------------------------
resource "aws_eks_cluster" "this" {
  name                      = "${local.prefix}-cluster"
  version                   = var.eks_version
  role_arn                  = aws_iam_role.eksrole.arn
  enabled_cluster_log_types = ["api", "audit"]

  vpc_config {
    endpoint_public_access  = var.public_access
    endpoint_private_access = var.private_access
    subnet_ids              = [var.eks_subnets[0].id, var.eks_subnets[1].id]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = {
    Name      = "${local.prefix}-cluster"
    CreatedAt = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_cloudwatch_log_group.this
  ]

  lifecycle {
    ignore_changes = [tags["CreatedAt"]]
  }
}

resource "aws_eks_access_entry" "this" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.ec2_role.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "this" {
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.ec2_role.arn
  access_scope {
    type = "cluster"
  }
}

resource "aws_security_group_rule" "this" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  depends_on = [
    aws_eks_cluster.this
  ]
}

# NodeGroups
resource "aws_launch_template" "this" {
  name     = "eks-ec2-launch-template"
  key_name = var.key_name
}

resource "aws_eks_node_group" "ec2_ondemand" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "ec2-ondemand"
  node_role_arn   = aws_iam_role.workernoderole.arn
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  subnet_ids      = [var.eks_subnets[0].id, var.eks_subnets[1].id]
  version         = aws_eks_cluster.this.version
  ami_type        = "AL2_x86_64"
  capacity_type   = var.capacity_type

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.default_version
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  tags = {
    Name      = "${local.prefix}-nodegroup-ec2-ondemand"
    CreatedAt = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
  }

  depends_on = [
    aws_iam_role_policy_attachment.WorkerNodePolicy,
    aws_iam_role_policy_attachment.EKS_CNI_Policy,
    aws_iam_role_policy_attachment.EC2ContainerRegistryReadOnly
  ]

  lifecycle {
    ignore_changes = [tags["CreatedAt"]]
  }
}

# Addons
resource "aws_eks_addon" "this" {
  for_each      = { for idx, addon in var.addons : idx => addon }
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = each.value.name
  addon_version = each.value.version
  depends_on = [
    aws_eks_node_group.ec2_ondemand
  ]
}

# CloudWatch
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/eks/${local.prefix}/cluster"
  retention_in_days = 7
}

# IAM
data "aws_iam_policy_document" "eksassumepolicy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eksrole" {
  name               = "${local.prefix}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eksassumepolicy.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eksrole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eksrole.name
}

resource "aws_iam_role" "workernoderole" {
  name = "${local.prefix}-eks-node-group-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "WorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workernoderole.name
}

resource "aws_iam_role_policy_attachment" "EKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workernoderole.name
}

resource "aws_iam_role_policy_attachment" "EC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workernoderole.name
}

# Security Groups
resource "aws_security_group" "this" {
  name        = "${local.prefix}-eks"
  description = "EKS ${local.prefix} default security group to allow inbound/outbound from the VPC"
  vpc_id      = var.vpc
  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${local.prefix}-eks"
    CreatedAt = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
  }

  lifecycle {
    ignore_changes = [tags["CreatedAt"]]
  }
}

# -----------------------------------------------------------------------------
# ALB
# -----------------------------------------------------------------------------
resource "aws_lb_target_group" "this" {
  name        = "${local.prefix}-eks"
  port = "443"
  protocol = "HTTP"
  vpc_id      = var.vpc
}

# -----------------------------------------------------------------------------
# Bastion Host
# -----------------------------------------------------------------------------
resource "aws_instance" "bastion" {
  count                  = var.create_bastion_host == true ? 1 : 0
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = var.ami_subnet
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.this.name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  user_data              = file("${path.module}/assets/userdata.sh")
  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.ec2_ondemand
  ]

  lifecycle {
    ignore_changes = [tags["CreatedAt"]]
  }
}

# Security Group
resource "aws_security_group" "bastion" {
  name        = "${local.prefix}-bastion"
  description = "EC2 Bastion security group to connect to the EKS cluster"
  vpc_id      = var.vpc
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.prefix}-bastion"
  }
}

# IAM
resource "aws_iam_role" "ec2_role" {
  name               = "${local.prefix}-ec2-instance-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "this" {
  name = "${local.prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy" "this" {
  name = "${local.prefix}-ec2-iam-role-policy"
  role = aws_iam_role.ec2_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
