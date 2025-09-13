variable "app_name" {}
variable "s3_buckets" {
  type = list(string)
}
variable "cloudfront_distribution_arn" {}
variable "lambda_arns" {
  type = map(string)
}