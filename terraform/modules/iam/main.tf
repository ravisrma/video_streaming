resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.app_name}-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "mediaconvert_role" {
  name = "${var.app_name}-mediaconvert-role"
  assume_role_policy = data.aws_iam_policy_document.mediaconvert_assume_role.json
}

data "aws_iam_policy_document" "mediaconvert_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["mediaconvert.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "mediaconvert_completion_role" {
  name = "${var.app_name}-mediaconvert-completion-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role" "s3_notification_config_role" {
  name = "${var.app_name}-s3-notification-config-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}