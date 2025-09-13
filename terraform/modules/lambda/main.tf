resource "aws_lambda_function" "mediaconvert_job" {
  function_name = "${var.app_name}-MediaConvertJob"
  role          = var.iam_roles["mediaconvert_role"]
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300
  s3_bucket     = var.s3_lambda_bucket
  s3_key        = "lambda-packages/mediaconvert_job.zip"
}

resource "aws_lambda_function" "video_stream" {
  function_name = "${var.app_name}-VideoStream"
  role          = var.iam_roles["lambda_execution_role"]
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300
  s3_bucket     = var.s3_lambda_bucket
  s3_key        = "lambda-packages/video_stream.zip"
}

resource "aws_lambda_function" "video_list" {
  function_name = "${var.app_name}-VideoList"
  role          = var.iam_roles["lambda_execution_role"]
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  s3_bucket     = var.s3_lambda_bucket
  s3_key        = "lambda-packages/video_list.zip"
}

resource "aws_lambda_function" "mediaconvert_completion" {
  function_name = "${var.app_name}-MediaConvertCompletion"
  role          = var.iam_roles["mediaconvert_completion_role"]
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300
  s3_bucket     = var.s3_lambda_bucket
  s3_key        = "lambda-packages/mediaconvert_completion.zip"
}

resource "aws_lambda_function" "s3_notification_config" {
  function_name = "${var.app_name}-S3NotificationConfig"
  role          = var.iam_roles["s3_notification_config_role"]
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60
  s3_bucket     = var.s3_lambda_bucket
  s3_key        = "lambda-packages/s3_notification_config.zip"
}