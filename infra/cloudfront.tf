# CloudFront distribution for frontend S3 bucket
resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                              = "frontend-oac"
  description                       = "OAC for S3 frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "frontendS3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "frontendS3Origin"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}

resource "aws_cloudfront_origin_access_identity" "frontend" {
  comment    = "OAI for frontend S3 bucket"
  depends_on = [aws_s3_bucket.frontend] # Ensure the S3 bucket is created before the OAI
}

output "frontend_cloudfront_domain" {
  value       = aws_cloudfront_distribution.frontend.domain_name
  description = "value of the CloudFront distribution domain name for the frontend S3 bucket"
}

output "aws_cloudfront_origin_access_identity_iam_arn" {
  value       = aws_cloudfront_origin_access_identity.frontend.iam_arn
  description = "IAM ARN of the CloudFront Origin Access Identity for the frontend S3 bucket"
}
