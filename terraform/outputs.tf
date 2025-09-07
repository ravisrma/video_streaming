output "s3_buckets" {
  value = module.s3
}
output "dynamodb_table" {
  value = module.dynamodb
}
output "cognito" {
  value = module.cognito
}
output "iam_roles" {
  value = module.iam
}
output "lambda_functions" {
  value = module.lambda
}
output "apigateway" {
  value = module.apigateway
}
output "cloudfront" {
  value = module.cloudfront
}
output "eventbridge" {
  value = module.eventbridge
}