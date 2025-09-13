resource "aws_cloudfront_distribution" "web_distribution" {
  origin {
    domain_name = var.web_bucket_regional_domain_name
    origin_id   = "webS3Origin"
  }
  enabled             = true
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "webS3Origin"
    viewer_protocol_policy = "redirect-to-https"
  }
  price_class = "PriceClass_100"
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}