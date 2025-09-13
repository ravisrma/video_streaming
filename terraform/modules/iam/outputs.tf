output "lambda_roles" {
  value = {
    lambda_execution_role        = aws_iam_role.lambda_execution_role.arn
    mediaconvert_role            = aws_iam_role.mediaconvert_role.arn
    mediaconvert_completion_role = aws_iam_role.mediaconvert_completion_role.arn
    s3_notification_config_role  = aws_iam_role.s3_notification_config_role.arn
  }
}