output "lambda_bucket_name" {
  value = module.s3.lambda_bucket_name
}
output "upload_bucket_name" {
  value = module.s3.upload_bucket_name
}
output "content_bucket_name" {
  value = module.s3.content_bucket_name
}
output "web_bucket_name" {
  value = module.s3.web_bucket_name
}
output "cloudfront_domain" {
  value = module.cloudfront.domain_name
}
output "api_gateway_url" {
  value = module.apigateway.api_gateway_url
}
output "user_pool_id" {
  value = module.cognito.user_pool_id
}
output "user_pool_client_id" {
  value = module.cognito.user_pool_client_id
}
output "identity_pool_id" {
  value = module.cognito.identity_pool_id
}
output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}
output "lambda_arns" {
  value = module.lambda.lambda_arns
}