provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

module "s3" {
  source     = "./modules/s3"
  app_name   = var.app_name
  account_id = data.aws_caller_identity.current.account_id
  mediaconvert_job_lambda_arn = module.lambda.lambda_arns["mediaconvert_job"]
  cloudfront_distribution_id = module.cloudfront.distribution_id
}

module "dynamodb" {
  source   = "./modules/dynamodb"
  app_name = var.app_name
}

module "cognito" {
  source   = "./modules/cognito"
  app_name = var.app_name
}

module "iam" {
  source    = "./modules/iam"
  app_name  = var.app_name
  s3_upload_bucket_arn  = module.s3.upload_bucket_arn
  s3_content_bucket_arn = module.s3.content_bucket_arn
  dynamodb_table_arn    = module.dynamodb.table_arn
  user_pool_id          = module.cognito.user_pool_id
  identity_pool_id      = module.cognito.identity_pool_id
}

module "lambda" {
  source   = "./modules/lambda"
  app_name = var.app_name
  s3_lambda_bucket = module.s3.lambda_deployment_bucket_name
  iam_roles = module.iam.lambda_roles
  dynamodb_table_name = module.dynamodb.table_name
  s3_content_bucket = module.s3.content_bucket_name
  cloudfront_domain = module.cloudfront.domain_name
  s3_upload_bucket_arn = module.s3.upload_bucket_arn
  s3_content_bucket_arn = module.s3.content_bucket_arn
}

module "apigateway" {
  source   = "./modules/apigateway"
  app_name = var.app_name
  aws_region = var.aws_region
  cognito_user_pool_id = module.cognito.user_pool_id
  lambda_arns = module.lambda.lambda_arns
}

module "cloudfront" {
  source   = "./modules/cloudfront"
  app_name = var.app_name
  web_bucket_regional_domain_name = module.s3.web_bucket_regional_domain_name
  content_bucket_regional_domain_name = module.s3.content_bucket_regional_domain_name
}

module "eventbridge" {
  source   = "./modules/eventbridge"
  app_name = var.app_name
  lambda_arn = module.lambda.mediaconvert_completion_lambda_arn
}