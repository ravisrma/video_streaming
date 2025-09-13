variable "app_name" {}
variable "lambda_arns" {
  type = map(string)
}
variable "cognito_user_pool_id" {}