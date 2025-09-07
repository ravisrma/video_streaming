output "lambda_deployment_bucket_name" {
  value = aws_s3_bucket.lambda_deployment.bucket
}
output "upload_bucket_name" {
  value = aws_s3_bucket.upload.bucket
}
output "content_bucket_name" {
  value = aws_s3_bucket.content.bucket
}
output "web_bucket_name" {
  value = aws_s3_bucket.web.bucket
}
output "upload_bucket_arn" {
  value = aws_s3_bucket.upload.arn
}
output "content_bucket_arn" {
  value = aws_s3_bucket.content.arn
}
output "web_bucket_regional_domain_name" {
  value = aws_s3_bucket.web.bucket_regional_domain_name
}
output "content_bucket_regional_domain_name" {
  value = aws_s3_bucket.content.bucket_regional_domain_name
}