resource "aws_route53_record" "cdn" {
  zone_id = var.dns_zone
  name    = var.dns
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "cert_validation" {
  name    = element(tolist(aws_acm_certificate.cert.domain_validation_options), 0).resource_record_name
  type    = element(tolist(aws_acm_certificate.cert.domain_validation_options), 0).resource_record_type
  zone_id = var.dns_zone
  records = [element(tolist(aws_acm_certificate.cert.domain_validation_options), 0).resource_record_value]
  ttl     = 60
}