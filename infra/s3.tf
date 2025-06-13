# Retrieve Account ID # to use in S3 bucket policy

data "aws_caller_identity" "current" {}

# S3 bucket for frontend static site
resource "aws_s3_bucket" "frontend" {
  bucket        = "${var.project_name}-frontend-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # tflint-ignore: terraform_deprecated_interpolation
          "AWS" = "${aws_cloudfront_origin_access_identity.frontend.iam_arn}"
        }
        Action   = ["s3:GetObject"]
        Resource = ["${aws_s3_bucket.frontend.arn}/*"]
      },
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = ["s3:*"]
        Resource  = ["${aws_s3_bucket.frontend.arn}/*"]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

output "frontend_s3_bucket" {
  description = "Name of the S3 bucket for the frontend static site"
  value       = aws_s3_bucket.frontend.bucket
}
