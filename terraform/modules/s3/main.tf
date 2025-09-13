resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.app_name}-lambda-deployments-${var.account_id}"
  acl    = "private"
}

resource "aws_s3_bucket" "upload_bucket" {
  bucket = "${var.app_name}-video-uploads-${var.account_id}"
  acl    = "private"
}

resource "aws_s3_bucket" "content_bucket" {
  bucket = "${var.app_name}-video-content-${var.account_id}"
  acl    = "private"
}

resource "aws_s3_bucket" "web_bucket" {
  bucket = "${var.app_name}-web-${var.account_id}"
  acl    = "private"
}