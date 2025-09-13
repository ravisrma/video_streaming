resource "aws_cloudwatch_event_rule" "mediaconvert_complete" {
  name        = "${var.app_name}-mediaconvert-complete"
  event_pattern = <<EOF
{
  "source": ["aws.mediaconvert"],
  "detail-type": ["MediaConvert Job State Change"],
  "detail": {
    "status": ["COMPLETE"]
  }
}
EOF
}
resource "aws_cloudwatch_event_target" "mediaconvert_completion_lambda" {
  rule = aws_cloudwatch_event_rule.mediaconvert_complete.name
  arn  = var.mediaconvert_completion_lambda_arn
}