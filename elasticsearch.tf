resource "aws_elasticsearch_domain" "cluster" {
  domain_name           = "${var.env}-${var.name}"
  elasticsearch_version = "OpenSearch_1.0"

  cluster_config {
    instance_type  = var.instance_type
    instance_count = var.instance_count
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.cluster.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.cluster.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  cognito_options {
    enabled = true
    user_pool_id = aws_cognito_user_pool.kibana.id
    identity_pool_id = aws_cognito_identity_pool.kibana.id
    role_arn = aws_iam_role.cognito_es_role.arn
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops = var.ebs_iops
  }

  tags = {
    Env = var.env
  }

  depends_on = [aws_iam_service_linked_role.es]
}

resource "aws_elasticsearch_domain_policy" "main" {
  domain_name = aws_elasticsearch_domain.cluster.domain_name
  access_policies = data.aws_iam_policy_document.es_access_policy.json
}