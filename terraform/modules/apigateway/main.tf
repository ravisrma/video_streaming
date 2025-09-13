
resource "aws_api_gateway_rest_api" "video_streaming_api" {
  name        = "${var.app_name}-API"
  description = "API for Video Streaming Application"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "videos" {
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
  parent_id   = aws_api_gateway_rest_api.video_streaming_api.root_resource_id
  path_part   = "videos"
}

resource "aws_api_gateway_resource" "stream" {
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
  parent_id   = aws_api_gateway_resource.videos.id
  path_part   = "stream"
}

resource "aws_api_gateway_resource" "list" {
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
  parent_id   = aws_api_gateway_resource.videos.id
  path_part   = "list"
}

resource "aws_api_gateway_resource" "video_id" {
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
  parent_id   = aws_api_gateway_resource.stream.id
  path_part   = "{videoId}"
}

data "aws_caller_identity" "current" {}

resource "aws_api_gateway_authorizer" "cognito" {
  name            = "CognitoAuthorizer"
  rest_api_id     = aws_api_gateway_rest_api.video_streaming_api.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = ["arn:aws:cognito-idp:${var.aws_region}:${data.aws_caller_identity.current.account_id}:userpool/${var.cognito_user_pool_id}"]
}

resource "aws_api_gateway_method" "stream_get" {
  rest_api_id   = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id   = aws_api_gateway_resource.video_id.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
  request_parameters = {
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "stream_get" {
  rest_api_id             = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id             = aws_api_gateway_resource.video_id.id
  http_method             = aws_api_gateway_method.stream_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_arns["video_stream"]
}

resource "aws_api_gateway_method_response" "stream_get" {
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id = aws_api_gateway_resource.video_id.id
  http_method = aws_api_gateway_method.stream_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}
resource "aws_api_gateway_method_response" "stream_options" {
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id = aws_api_gateway_resource.video_id.id
  http_method = aws_api_gateway_method.stream_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "list_options" {
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id = aws_api_gateway_resource.list.id
  http_method = aws_api_gateway_method.list_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
resource "aws_api_gateway_integration_response" "stream_get" {
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id = aws_api_gateway_resource.video_id.id
  http_method = aws_api_gateway_method.stream_get.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method" "list_get" {
  rest_api_id   = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id   = aws_api_gateway_resource.list.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
  request_parameters = {
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "list_get" {
  rest_api_id             = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id             = aws_api_gateway_resource.list.id
  http_method             = aws_api_gateway_method.list_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_arns["video_list"]
}

resource "aws_api_gateway_method_response" "list_get" {
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id = aws_api_gateway_resource.list.id
  http_method = aws_api_gateway_method.list_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration_response" "list_get" {
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id = aws_api_gateway_resource.list.id
  http_method = aws_api_gateway_method.list_get.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method" "stream_options" {
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id = aws_api_gateway_resource.video_id.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "stream_options" {
  rest_api_id             = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id             = aws_api_gateway_resource.video_id.id
  http_method             = aws_api_gateway_method.stream_options.http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "stream_options" {
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id = aws_api_gateway_resource.video_id.id
  http_method = aws_api_gateway_method.stream_options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method" "list_options" {
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id = aws_api_gateway_resource.list.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "list_options" {
  rest_api_id             = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id             = aws_api_gateway_resource.list.id
  http_method             = aws_api_gateway_method.list_options.http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "list_options" {
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
  resource_id = aws_api_gateway_resource.list.id
  http_method = aws_api_gateway_method.list_options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_deployment" "prod" {
  depends_on = [
    aws_api_gateway_integration.stream_get,
    aws_api_gateway_integration.list_get,
    aws_api_gateway_integration.stream_options,
    aws_api_gateway_integration.list_options
  ]
  rest_api_id = aws_api_gateway_rest_api.video_streaming_api.id
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.video_streaming_api.id
  deployment_id = aws_api_gateway_deployment.prod.id
  stage_name    = "prod"
}