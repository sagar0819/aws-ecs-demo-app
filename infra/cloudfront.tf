resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "frontendS3Origin"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend.cloudfront_access_identity_path
    }
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
      # No headers forwarded for S3 origin
    }
  }

  price_class = "PriceClass_100"

  # Correct block names for restrictions and viewer_certificate
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
