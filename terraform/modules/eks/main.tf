data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-${var.environment}-cluster"
  role_arn = data.aws_iam_role.lab_role.arn

  vpc_config {
    subnet_ids         = concat(var.public_subnet_ids, var.private_subnet_ids)
    security_group_ids = [var.eks_nodes_security_group_id]
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.environment}-node-group"
  node_role_arn   = data.aws_iam_role.lab_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_group_desired_capacity
    min_size     = var.node_group_min_size
    max_size     = var.node_group_max_size
  }

  instance_types = [var.node_group_instance_type]
}