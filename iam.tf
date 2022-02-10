data "aws_iam_policy_document" "cognito_es_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "cognito-idp:DescribeUserPool",
      "cognito-idp:CreateUserPoolClient",
      "cognito-idp:DeleteUserPoolClient",
      "cognito-idp:DescribeUserPoolClient",
      "cognito-idp:AdminInitiateAuth",
      "cognito-idp:AdminUserGlobalSignOut",
      "cognito-idp:ListUserPoolClients",
      "cognito-identity:DescribeIdentityPool",
      "cognito-identity:UpdateIdentityPool",
      "cognito-identity:SetIdentityPoolRoles",
      "cognito-identity:GetIdentityPoolRoles"
    ]
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "es_assume_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "es_access_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.authenticated.arn]
    }
    actions = ["es:*"]
    resources = ["${aws_elasticsearch_domain.cluster.arn}/*"]
  }
}

resource "aws_iam_service_linked_role" "es" {
  count = ((var.env == "dev") || (var.env == "prod")) ? 1 : 0
  aws_service_name = "es.amazonaws.com"
}

resource "aws_iam_policy" "cognito_es_policy" {
  name = "${var.env}-${var.name}-COGNITO-ACCESS-ES-POLICY"
  policy = data.aws_iam_policy_document.cognito_es_policy.json
}


resource "aws_iam_role" "cognito_es_role" {
  name = "${var.env}-${var.name}-COGNITO-ACCESS-ES-ROLE"
  assume_role_policy = data.aws_iam_policy_document.es_assume_policy.json

}

resource "aws_iam_role_policy_attachment" "cognito_es_attach" {
  role       = aws_iam_role.cognito_es_role.name
  policy_arn = aws_iam_policy.cognito_es_policy.arn
}


resource "aws_iam_role" "authenticated" {
  name = "${var.env}-${var.name}-AUTH-ROLE"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
    "Effect": "Allow",
    "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
        "StringEquals": {
        "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.kibana.id}"
        },
        "ForAnyValue:StringLike": {
        "cognito-identity.amazonaws.com:amr": "authenticated"
        }
    }
    }
]
}
EOF

}

resource "aws_iam_role_policy" "authenticated" {
  name = "${var.env}${var.name}-authenticated_policy"
  role = aws_iam_role.authenticated.id

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
  "Effect": "Allow",
  "Action": [
      "mobileanalytics:PutEvents",
      "cognito-sync:*"
  ],
  "Resource": [
      "*"
  ]
  }
]
}
EOF
}

resource "aws_iam_role" "unauthenticated" {
  name = "${var.env}-${var.name}-UNAUTH-ROLE"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
  "Effect": "Allow",
  "Principal": {
      "Federated": "cognito-identity.amazonaws.com"
  },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
      "StringEquals": {
      "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.kibana.id}"
      },
      "ForAnyValue:StringLike": {
      "cognito-identity.amazonaws.com:amr": "unauthenticated"
      }
  }
  }
]
}
EOF
}

resource "aws_iam_role_policy" "unauthenticated" {
  name = "authenticated_policy"
  role = aws_iam_role.authenticated.id

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
  "Effect": "Allow",
  "Action": [
      "mobileanalytics:PutEvents",
      "cognito-sync:*"
  ],
  "Resource": [
      "*"
  ]
  }
]
}
EOF
}

resource "aws_cognito_identity_pool_roles_attachment" "identity_pool" {
  identity_pool_id = aws_cognito_identity_pool.kibana.id
  roles = {
    "authenticated" = aws_iam_role.authenticated.arn
    "unauthenticated" = aws_iam_role.unauthenticated.arn
  }
}