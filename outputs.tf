output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "bastion_public_ip" {
  value = aws_instance.bastion[count.index].public_ip
}
