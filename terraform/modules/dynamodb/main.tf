resource "aws_dynamodb_table" "video_metadata" {
  name         = "${var.app_name}-VideoMetadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "videoId"

  attribute {
    name = "videoId"
    type = "S"
  }
  attribute {
    name = "uploadDate"
    type = "S"
  }
  attribute {
    name = "status"
    type = "S"
  }

  global_secondary_index {
    name            = "StatusIndex"
    hash_key        = "status"
    range_key       = "uploadDate"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "UploadDateIndex"
    hash_key        = "uploadDate"
    projection_type = "ALL"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = {
    Project = var.app_name
    Purpose = "VideoMetadata"
  }
}