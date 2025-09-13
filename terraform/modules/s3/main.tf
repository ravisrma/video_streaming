resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.app_name}-lambda-deployments-${var.aws_account_id}"
  acl    = "private"
}

resource "aws_s3_bucket" "upload_bucket" {
  bucket = "${var.app_name}-video-uploads-${var.aws_account_id}"
  acl    = "private"
}

resource "aws_s3_bucket" "content_bucket" {
  bucket = "${var.app_name}-video-content-${var.aws_account_id}"
  acl    = "private"
}

resource "aws_s3_bucket" "web_bucket" {
  bucket = "${var.app_name}-web-${var.aws_account_id}"
  acl    = "private"
}