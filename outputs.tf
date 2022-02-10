output "endpoint" {
  value = "https://${var.dns}"
}
output "kibana_endpoint" {
  value = "https://${aws_elasticsearch_domain.cluster.kibana_endpoint}"
}
output "cloudfront_id" {
  value = aws_cloudfront_distribution.cdn.id
}
output "cloudfront_arn" {
  value = aws_cloudfront_distribution.cdn.arn
}
