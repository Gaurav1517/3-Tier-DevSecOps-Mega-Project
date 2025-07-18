output "cluster_id" {
  value = aws_eks_cluster.myproject.id
}

output "node_group_id" {
  value = aws_eks_node_group.myproject.id
}

output "vpc_id" {
  value = aws_vpc.myproject_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.myproject_subnet[*].id
}
