variable "lambda_arns" {
	type        = map(string)
	description = "Map of Lambda ARNs for API Gateway integrations"
}
variable "app_name" {
	type        = string
	description = "Application name"
}

variable "aws_region" {
	type        = string
	description = "AWS region for resources"
}

variable "cognito_user_pool_id" {
	type        = string
	description = "Cognito User Pool ID for authorizer"
}