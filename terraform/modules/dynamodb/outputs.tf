output "table_name" {
  value = aws_dynamodb_table.video_metadata.name
}
output "table_arn" {
  value = aws_dynamodb_table.video_metadata.arn
}