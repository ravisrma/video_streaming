resource "aws_s3_bucket" "lambda_deployment" {
  bucket = "${var.app_name}-lambda-deployments-${var.account_id}"
}

resource "aws_s3_bucket_versioning" "lambda_deployment_versioning" {
  bucket = aws_s3_bucket.lambda_deployment.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_deployment_encryption" {
  bucket = aws_s3_bucket.lambda_deployment.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "lambda_deployment_policy" {
  bucket = aws_s3_bucket.lambda_deployment.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowCloudFormationAccess"
        Effect = "Allow"
        Principal = { Service = "cloudformation.amazonaws.com" }
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.lambda_deployment.arn}/*"
      },
      {
        Sid = "AllowLambdaAccess"
        Effect = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.lambda_deployment.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket" "upload" {
  bucket = "${var.app_name}-video-uploads-${var.account_id}"
}

resource "aws_s3_bucket_cors_configuration" "upload_cors" {
  bucket = aws_s3_bucket.upload.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

# Custom resource for S3 bucket notification
# Custom resource for S3 bucket notification
resource "null_resource" "s3_bucket_notification" {
  triggers = {
    bucket_name        = aws_s3_bucket.upload.bucket
    lambda_function_arn = var.mediaconvert_job_lambda_arn
    notification_id    = "VideoProcessingTrigger"
  }
  provisioner "local-exec" {
    command = "echo 'Configure S3 notification for bucket ${self.triggers.bucket_name} to Lambda ${self.triggers.lambda_function_arn}'"
    # Replace with actual AWS CLI or script for notification config
  }
}

resource "aws_s3_bucket" "content" {
  bucket = "${var.app_name}-video-content-${var.account_id}"
}

resource "aws_s3_bucket_cors_configuration" "content_cors" {
  bucket = aws_s3_bucket.content.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "content_bucket_policy" {
  bucket = aws_s3_bucket.content.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.content.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${var.account_id}:distribution/${var.cloudfront_distribution_id}"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket" "web" {
  bucket = "${var.app_name}-web-${var.account_id}"
}

resource "aws_s3_bucket_policy" "web_bucket_policy" {
  bucket = aws_s3_bucket.web.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.web.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${var.account_id}:distribution/${var.cloudfront_distribution_id}"
          }
        }
      }
    ]
  })
}
