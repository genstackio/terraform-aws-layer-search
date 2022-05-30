module "lambda-edge" {
  source            = "genstackio/lambda/aws"
  version           = "0.3.0"
  file              = data.archive_file.lambda-edge-code.output_path
  name              = "${var.env}-edge-${var.name}"
  runtime           = "nodejs14.x"
  handler           = "index.handler"
  timeout           = 10
  memory_size       = 128
  publish           = true
  assume_role_identifiers = ["edgelambda.amazonaws.com"]
  providers = {
    aws = aws.central
  }
  policy_statements = [
    {
      resources = ["${aws_elasticsearch_domain.cluster.arn}/*"]
      actions   = [
        "es:ESHttp*"
      ]
      effect    = "Allow"
    }
  ]
}
data "archive_file" "lambda-edge-code" {
  type        = "zip"
  output_path = "${path.module}/lambda-code.zip"
  source {
    content  = file("${path.module}/lambdas/origin-request.js")
    filename = "index.js"
  }
}