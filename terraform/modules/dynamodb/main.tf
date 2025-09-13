resource "aws_dynamodb_table" "video_metadata" {
  name         = "${var.app_name}-video-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "videoId"
  attribute {
    name = "videoId"
    type = "S"
  }
}