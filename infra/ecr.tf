# This file defines the AWS ECR repository for the backend service of the demo application.

# ECR repository for backend
resource "aws_ecr_repository" "backend" {
  name = var.ecr_repo_name
  image_scanning_configuration {
    scan_on_push = true
  }
  image_tag_mutability = "IMMUTABLE"
}

output "ecr_repo_url" {
  description = "URL of the ECR repository for the backend service"
  value       = aws_ecr_repository.backend.repository_url
}
