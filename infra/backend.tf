terraform {
  backend "s3" {
    bucket = "sagar-github-tf-backend"
    key    = "terraform.tfstate"
    region = var.aws_region
  }
}

# locals {
#   name = "ecs-demo-app"
# }