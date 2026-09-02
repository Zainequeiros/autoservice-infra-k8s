variable "project_name" {
  description = "Base name of the project."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region where the EKS cluster is created."
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster."
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "VPC identifier where the EKS cluster is created."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets reserved for the EKS node groups."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnets used for the ingress and public access."
  type        = list(string)
}

variable "eks_nodes_security_group_id" {
  description = "Security group for the managed node group."
  type        = string
}

variable "node_group_instance_type" {
  description = "EC2 instance type for the managed node group."
  type        = string
  default     = "t3.medium"
}

variable "node_group_desired_capacity" {
  description = "Desired count for the managed node group."
  type        = number
  default     = 2
}

variable "node_group_min_size" {
  description = "Minimum count for the managed node group."
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum count for the managed node group."
  type        = number
  default     = 4
}
