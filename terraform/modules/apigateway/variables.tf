variable "project_name" {
  description = "Base name of the project."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region for the API Gateway and load balancer."
  type        = string
}

variable "vpc_id" {
  description = "VPC identifier used by the load balancer target group."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for the ingress ALB."
  type        = list(string)
}

variable "ingress_security_group_id" {
  description = "Security group between the public ALB and the internet."
  type        = string
}

variable "node_group_autoscaling_group_name" {
  description = "Auto Scaling Group attached to the ALB target group."
  type        = string
}
