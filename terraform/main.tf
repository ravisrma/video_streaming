provider "aws" {
  region = var.aws_region
}
data "aws_caller_identity" "current" {}
module "s3" {
  source = "./modules/s3"
  app_name = var.app_name
  account_id = data.aws_caller_identity.current.account_id
}

module "iam" {
  source = "./modules/iam"
  app_name = var.app_name
  s3_buckets = module.s3.bucket_names
}

module "cognito" {
  source = "./modules/cognito"
  app_name = var.app_name
}

module "dynamodb" {
  source = "./modules/dynamodb"
  app_name = var.app_name
}

module "lambda" {
  source = "./modules/lambda"
  app_name = var.app_name
  s3_lambda_bucket = module.s3.lambda_bucket_name
  iam_roles = module.iam.lambda_roles
  dynamodb_table_name = module.dynamodb.table_name
  s3_content_bucket = module.s3.content_bucket_name
  cloudfront_domain = module.cloudfront.domain_name
  s3_upload_bucket_arn = module.s3.upload_bucket_arn
  s3_content_bucket_arn = module.s3.content_bucket_arn
}

module "apigateway" {
  source = "./modules/apigateway"
  app_name = var.app_name
  lambda_arns = module.lambda.lambda_arns
  cognito_user_pool_id = module.cognito.user_pool_id
}

module "cloudfront" {
  source = "./modules/cloudfront"
  app_name = var.app_name
  web_bucket_regional_domain_name = module.s3.web_bucket_regional_domain_name
  content_bucket_regional_domain_name = module.s3.content_bucket_regional_domain_name
}

module "eventbridge" {
  source = "./modules/eventbridge"
  app_name = var.app_name
  mediaconvert_completion_lambda_arn = module.lambda.mediaconvert_completion_lambda_arn
}

module "bucket_policy" {
  source = "./modules/bucket_policy"
  app_name = var.app_name
  s3_buckets = module.s3.bucket_names
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
  lambda_arns = module.lambda.lambda_arns
}