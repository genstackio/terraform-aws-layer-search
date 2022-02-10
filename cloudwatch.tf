resource "aws_cloudwatch_log_group" "cluster" {
  name = "/aws/elasticsearch/${var.env}-${var.name}"

  tags = {
    Env = var.env
  }
}

resource "aws_cloudwatch_log_resource_policy" "cluster" {
  policy_name = "${var.env}-${var.name}-policy"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}
