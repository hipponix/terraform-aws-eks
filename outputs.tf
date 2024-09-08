output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "sgid" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "eks" {
  value = aws_eks_cluster.this
}
