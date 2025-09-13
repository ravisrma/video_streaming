variable "app_name" {}
variable "s3_lambda_bucket" {}
variable "iam_roles" {}
variable "dynamodb_table_name" {}
variable "s3_content_bucket" {}
variable "cloudfront_domain" {}

variable "s3_upload_bucket_arn" {
    description = "ARN of the S3 upload bucket for Lambda invoke permissions"
    type        = string
}

variable "s3_content_bucket_arn" {
    description = "ARN of the S3 content bucket for Lambda invoke permissions"
    type        = string
}