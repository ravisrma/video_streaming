output "lambda_arns" {
  value = {
    mediaconvert_job         = aws_lambda_function.mediaconvert_job.arn
    video_stream             = aws_lambda_function.video_stream.arn
    video_list               = aws_lambda_function.video_list.arn
    mediaconvert_completion  = aws_lambda_function.mediaconvert_completion.arn
    s3_notification_config   = aws_lambda_function.s3_notification_config.arn
  }
}
output "mediaconvert_completion_lambda_arn" {
  value = aws_lambda_function.mediaconvert_completion.arn
}