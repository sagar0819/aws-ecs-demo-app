terraform {
  backend "s3" {
    bucket = "sagar-github-tf-backend"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

# locals {
#   name = "ecs-demo-app"
# }