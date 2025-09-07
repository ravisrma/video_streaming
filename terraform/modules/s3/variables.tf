variable "app_name" {}
variable "account_id" {}

variable "mediaconvert_job_lambda_arn" {
	description = "ARN of the MediaConvert job Lambda function for S3 notification"
	type        = string
}

variable "cloudfront_distribution_id" {
	description = "CloudFront distribution ID for bucket policy"
	type        = string
}