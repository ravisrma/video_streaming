resource "aws_lambda_function" "mediaconvert_job" {
  function_name = "${var.app_name}-MediaConvertJob"
  role          = var.iam_roles["mediaconvert_role"]
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300
  environment {
    variables = {
      OUTPUT_BUCKET     = var.s3_content_bucket
      MEDIACONVERT_ROLE = var.iam_roles["mediaconvert_role"]
      AWS_ACCOUNT_ID    = ""
    }
  }
  filename      = "${path.module}/../../lambda-packages/video-processor.zip"
}

resource "aws_lambda_function" "video_stream" {
  function_name = "${var.app_name}-VideoStream"
  role          = var.iam_roles["lambda_execution_role"]
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
      CLOUDFRONT_DOMAIN   = var.cloudfront_domain
    }
  }
  filename      = "${path.module}/../../lambda-packages/video-streamer.zip"
}

resource "aws_lambda_function" "video_list" {
  function_name = "${var.app_name}-VideoList"
  role          = var.iam_roles["lambda_execution_role"]
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
    }
  }
  filename      = "${path.module}/../../lambda-packages/video-lister.zip"
  timeout       = 30
}

resource "aws_lambda_function" "s3_notification_config" {
  function_name = "${var.app_name}-S3NotificationConfig"
  role          = var.iam_roles["s3_notification_config_role"]
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60
  filename      = "${path.module}/../../lambda-packages/s3_notification_config.zip"
}

resource "aws_lambda_function" "mediaconvert_completion" {
  function_name = "${var.app_name}-MediaConvertCompletion"
  role          = var.iam_roles["mediaconvert_completion_role"]
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
      OUTPUT_BUCKET       = var.s3_content_bucket
      CLOUDFRONT_DOMAIN   = var.cloudfront_domain
    }
  }
  filename      = "${path.module}/../../lambda-packages/mediaconvert_completion_handler.zip"
}

resource "aws_lambda_permission" "mediaconvert_job_s3_invoke" {
  statement_id  = "AllowS3InvokeMediaConvertJob"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mediaconvert_job.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_upload_bucket_arn
}

resource "aws_lambda_permission" "mediaconvert_completion_eventbridge_invoke" {
  statement_id  = "AllowEventBridgeInvokeMediaConvertCompletion"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mediaconvert_completion.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.s3_content_bucket_arn
}

resource "aws_lambda_permission" "video_stream_apigateway_invoke" {
  statement_id  = "AllowAPIGatewayInvokeVideoStream"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.video_stream.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "video_list_apigateway_invoke" {
  statement_id  = "AllowAPIGatewayInvokeVideoList"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.video_list.function_name
  principal     = "apigateway.amazonaws.com"
}