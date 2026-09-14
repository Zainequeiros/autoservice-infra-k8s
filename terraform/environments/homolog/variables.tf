variable "project_name" {
  description = "Project name used in tags and resource names."
  type        = string
  default     = "autoservice"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "homolog"
}

variable "aws_region" {
  description = "AWS region for the environment."
  type        = string
  default     = "us-east-1"
}

variable "cluster_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.29"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "azs" {
  description = "Availability zones for the environment."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnets of the environment."
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnets of the environment."
  type        = list(string)
  default     = ["10.10.11.0/24", "10.10.12.0/24"]
}

variable "node_group_instance_type" {
  description = "EC2 instance type for the managed node group."
  type        = string
  default     = "t3.medium"
}

variable "node_group_desired_capacity" {
  description = "Desired capacity for the node group."
  type        = number
  default     = 2
}

variable "node_group_min_size" {
  description = "Minimum size for the node group."
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum size for the node group."
  type        = number
  default     = 4
}

variable "enable_datadog_agent" {
  description = "Install Datadog Agent via Helm in the EKS cluster."
  type        = bool
  default     = false
}

variable "dd_api_key" {
  description = "Datadog API key for the Agent (required when enable_datadog_agent is true)."
  type        = string
  sensitive   = true
  default     = ""
}

variable "dd_site" {
  description = "Datadog site (datadoghq.com, datadoghq.eu, etc.)."
  type        = string
  default     = "datadoghq.com"
}
