resource "aws_iam_role" "mediaconvert_role" {
  name = "${var.app_name}-MediaConvertRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "mediaconvert.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
  # managed_policy_arns deprecated; use aws_iam_role_policy_attachment below
}

resource "aws_iam_role_policy" "mediaconvert_s3_access" {
  name = "S3Access"
  role = aws_iam_role.mediaconvert_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject"]
        Resource = [
          "${var.s3_upload_bucket_arn}/*",
          "${var.s3_content_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.app_name}-LambdaExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
  # managed_policy_arns deprecated; use aws_iam_role_policy_attachment below
}

resource "aws_iam_role_policy" "lambda_video_streaming_policy" {
  name = "VideoStreamingPolicy"
  role = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${var.s3_upload_bucket_arn}/*",
          "${var.s3_content_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [
          var.dynamodb_table_arn,
          "${var.dynamodb_table_arn}/index/*"
        ]
      }
    ]
  })
}
resource "aws_iam_role" "s3_notification_config_role" {
  name = "${var.app_name}-S3NotificationConfigRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
  # managed_policy_arns deprecated; use aws_iam_role_policy_attachment below
}

resource "aws_iam_role_policy" "s3_notification_config_policy" {
  name = "S3NotificationConfigPolicy"
  role = aws_iam_role.s3_notification_config_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetBucketNotification", "s3:PutBucketNotification"],
        Resource = var.s3_upload_bucket_arn
      }
    ]
  })
}

resource "aws_iam_role" "mediaconvert_completion_role" {
  name = "${var.app_name}-MediaConvertCompletionLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
  # managed_policy_arns deprecated; use aws_iam_role_policy_attachment below
}

# Place all aws_iam_role_policy_attachment resources at the end of the file, outside any resource block
resource "aws_iam_role_policy_attachment" "mediaconvert_full_access" {
  role       = aws_iam_role.mediaconvert_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElementalMediaConvertFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_notification_config_basic_execution" {
  role       = aws_iam_role.s3_notification_config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "mediaconvert_completion_basic_execution" {
  role       = aws_iam_role.mediaconvert_completion_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "mediaconvert_completion_dynamodb_policy" {
  name = "DynamoDBAccess"
  role = aws_iam_role.mediaconvert_completion_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:GetItem", "dynamodb:Scan"],
        Resource = [var.dynamodb_table_arn, "${var.dynamodb_table_arn}/index/*"]
      }
    ]
  })
}