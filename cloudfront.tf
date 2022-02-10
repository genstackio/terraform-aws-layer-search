resource "aws_cloudfront_function" "function" {
  for_each = local.functions
  name    = "${var.env}-${var.name}-${each.key}"
  runtime = "cloudfront-js-1.0"
  comment = "${each.key} function"
  publish = true
  code    = lookup(each.value, "code", null)
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name         = aws_elasticsearch_domain.cluster.endpoint
    origin_id           = "origin"
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
    dynamic custom_header {
      for_each = var.edge_lambdas_variables
      content {
        name  = "x-lambda-var-${replace(lower(custom_header.key), "_", "-")}"
        value = custom_header.value
      }
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.env} ${var.name} Distribution"

  aliases = [var.dns]

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "origin"

    forwarded_values {
      query_string = true
      headers      = concat(
        (null == var.forwarded_headers) ? [] : var.forwarded_headers,
        ["X-HTTP-Method-Override"] // required for GET method that have a body.
      )
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 86400
    compress               = true

    dynamic "function_association" {
      for_each = local.functions
      content {
        event_type   = lookup(function_association.value, "event_type", null)
        function_arn = aws_cloudfront_function.function[function_association.key].arn
      }
    }

    dynamic "lambda_function_association" {
      for_each = local.edge_lambdas
      content {
        event_type   = lookup(lambda_function_association.value, "event_type", null)
        lambda_arn   = lookup(lambda_function_association.value, "lambda_arn", null)
        include_body = lookup(lambda_function_association.value, "include_body", null)
      }
    }

  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = length(var.geolocations) == 0 ? "none" : "whitelist"
      locations        = length(var.geolocations) == 0 ? null : var.geolocations
    }
  }

  tags = {
    Env = var.env
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

}
