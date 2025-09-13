output "lambda_bucket_name" {
  value = aws_s3_bucket.lambda_bucket.bucket
}
output "upload_bucket_name" {
  value = aws_s3_bucket.upload_bucket.bucket
}
output "content_bucket_name" {
  value = aws_s3_bucket.content_bucket.bucket
}
output "web_bucket_name" {
  value = aws_s3_bucket.web_bucket.bucket
}
output "bucket_names" {
  value = [
    aws_s3_bucket.lambda_bucket.bucket,
    aws_s3_bucket.upload_bucket.bucket,
    aws_s3_bucket.content_bucket.bucket,
    aws_s3_bucket.web_bucket.bucket
  ]
}
output "web_bucket_regional_domain_name" {
  value = aws_s3_bucket.web_bucket.bucket_regional_domain_name
}
output "content_bucket_regional_domain_name" {
  value = aws_s3_bucket.content_bucket.bucket_regional_domain_name
}
output "upload_bucket_arn" {
  value = aws_s3_bucket.upload_bucket.arn
}
output "content_bucket_arn" {
  value = aws_s3_bucket.content_bucket.arn
}