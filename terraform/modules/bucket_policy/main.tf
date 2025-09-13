resource "aws_s3_bucket_policy" "web_bucket_policy" {
  bucket = var.s3_buckets[3]
  policy = data.aws_iam_policy_document.web_bucket_policy.json
}
data "aws_iam_policy_document" "web_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3_buckets[3]}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}