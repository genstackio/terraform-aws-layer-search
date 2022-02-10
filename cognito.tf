resource "aws_cognito_user_pool" "kibana" {
  name = "${var.env}-${var.name}-kibana-users"
}

resource "aws_cognito_user_pool_domain" "kibana" {
  domain       = "${var.env}-${var.name}"
  user_pool_id = aws_cognito_user_pool.kibana.id
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "${var.env}-${var.name}"
  user_pool_id = aws_cognito_user_pool.kibana.id
}

resource "aws_cognito_identity_pool" "kibana" {
  identity_pool_name               = "${var.env}-${var.name}-kibana-users"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id
    provider_name           = aws_cognito_user_pool.kibana.endpoint
    server_side_token_check = true
  }

  lifecycle {ignore_changes = [cognito_identity_providers]}
}
