locals {
  internal_functions = [
    {
      name       = "auth"
      code       = replace(file("${path.module}/functions/security.js"), "{{{JWT_SECRET}}}", var.jwt_secret)
      event_type = "viewer-request"
    }
  ]
  internal_edge_lambdas = [
    {
      event_type   = "origin-request"
      lambda_arn   = module.lambda-edge.qualified_arn
      include_body = true
    }
  ]
  functions = {for k, v in concat(local.internal_functions, var.functions): lookup(v, "name", k) => v}
  edge_lambdas = {for i,l in concat(local.internal_edge_lambdas, var.edge_lambdas): "lambda-${i}" => l}
}