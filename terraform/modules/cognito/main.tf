resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.app_name}-UserPool"
  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = "Your verification code for Video Streaming App is {####}"
    email_subject        = "Video Streaming App - Verify your email"
  }

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
  }

  schema {
    name     = "email"
    attribute_data_type = "String"
    required = true
    mutable  = true
  }

  schema {
    name     = "subscription_type"
    attribute_data_type = "String"
    required = false
    mutable  = true
    developer_only_attribute = false
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "${var.app_name}-Client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  generate_secret = false
  explicit_auth_flows = [
    "ADMIN_NO_SRP_AUTH",
    "USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
  access_token_validity  = 24
  id_token_validity      = 24
  refresh_token_validity = 30
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
  prevent_user_existence_errors = "ENABLED"
  supported_identity_providers  = ["COGNITO"]
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "${var.app_name}-IdentityPool"
  allow_unauthenticated_identities = false
  cognito_identity_providers {
    client_id   = aws_cognito_user_pool_client.user_pool_client.id
    provider_name = aws_cognito_user_pool.user_pool.endpoint
  }
}

resource "aws_iam_role" "authenticated_role" {
  name = "${var.app_name}-authenticated-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Federated = "cognito-identity.amazonaws.com" },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.identity_pool.id
        },
        "ForAnyValue:StringLike" = {
          "cognito-identity.amazonaws.com:amr" = "authenticated"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "authenticated_user_policy" {
  name = "AuthenticatedUserPolicy"
  role = aws_iam_role.authenticated_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject"],
        Resource = "arn:aws:s3:::${var.app_name}-video-content-*/*"
      },
      {
        Effect = "Allow",
        Action = ["execute-api:Invoke"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_cognito_identity_pool_roles_attachment" "identity_pool_role_attachment" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id
  roles = {
    authenticated = aws_iam_role.authenticated_role.arn
  }
}