variable "env" {
  type = string
}
variable "name" {
  type = string
}
variable "dns" {
  type = string
}
variable "dns_zone" {
  type = string
}
variable "geolocations" {
  type    = list(string)
  default = []
}
variable "forward_query_string" {
  type    = bool
  default = null
}
variable "price_class" {
  type    = string
  default = "PriceClass_100"
}
variable "accesslogs_s3_bucket" {
  type    = string
  default = null
}
variable "edge_lambdas" {
  type = list(object({
    event_type = string
    lambda_arn = string
    include_body = bool
  }))
  default = []
}
variable "edge_lambdas_variables" {
  type    = map(string)
  default = {}
}
variable "functions" {
  type = list(object({
    event_type = string
    function_arn = string
  }))
  default = []
}
variable "forwarded_headers" {
  type    = list(string)
  default = null
}
variable "jwt_secret" {
  type = string
}
variable "instance_type" {
  type    = string
  default = "t3.small.search"
}
variable "instance_count" {
  type    = number
  default = null
}
variable "ebs_enabled" {
  type = bool
  default = true
}
variable "ebs_volume_size" {
  type = number
  default = 10
}
variable "ebs_volume_type" {
  type = string
  default = null
}
variable "ebs_iops" {
  type = number
  default = null
}