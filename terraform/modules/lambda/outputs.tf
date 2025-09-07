output "lambda_arns" {
  value = {
    mediaconvert_job = aws_lambda_function.mediaconvert_job.arn
    video_stream     = aws_lambda_function.video_stream.arn
    video_list       = aws_lambda_function.video_list.arn
  }
}
output "mediaconvert_completion_lambda_arn" {
  value = aws_lambda_function.mediaconvert_job.arn
}
