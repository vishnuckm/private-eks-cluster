output "endpoint" {
  value = aws_eks_cluster.cloudquick.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.cloudquick.certificate_authority[0].data
}
output "cluster_id" {
  value = aws_eks_cluster.cloudquick.id
}
output "cluster_endpoint" {
  value = aws_eks_cluster.cloudquick.endpoint
}
output "cluster_name" {
  value = aws_eks_cluster.cloudquick.name
}
