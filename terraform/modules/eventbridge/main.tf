resource "aws_cloudwatch_event_rule" "mediaconvert_event_rule" {
  name        = "${var.app_name}-MediaConvertJobStatusRule"
  description = "Capture MediaConvert job status changes"
  event_pattern = <<EOF
{
  "source": ["aws.mediaconvert"],
  "detail-type": ["MediaConvert Job State Change"],
  "detail": {
    "status": ["COMPLETE", "ERROR"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "mediaconvert_completion_target" {
  rule = aws_cloudwatch_event_rule.mediaconvert_event_rule.name
  arn  = var.lambda_arn
}