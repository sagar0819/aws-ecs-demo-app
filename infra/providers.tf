provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0" # Ensure to use a compatible version with your AWS provider
    }
  }
}

variable "aws_region" {
  default     = "us-east-1"
  description = "AWS region where resources will be created"
  type        = string
}

variable "project_name" {
  default     = "ecs-demo-app"
  description = "Name of the project for resource naming"
  type        = string
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository for the backend service"
  default     = "ecs-demo-backend"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for ALB Target Group"
  type        = string
}

variable "ecs_subnet_ids" {
  description = "List of subnet IDs for the ECS service"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for the ECS service"
  type        = string
}
