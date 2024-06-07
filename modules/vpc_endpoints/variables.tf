variable "aws_account_abbreviation" {
  type = string
  validation {
    condition     = length(var.aws_account_abbreviation) < 4
    error_message = "Abbreviation must be 3 letters max."
  }
  description = "3 letter aws account abbreviation"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to associate security groups with."
}

variable "vpc_endpoints" {
  type        = any
  description = "Creates custom vpc endpoints with options defined from the aws provider for aws_vpc_endpoint resource Eg. vpc_endpoints = {lambda = {service_name = \"com.amazonaws.us-east-1.lambda\", vpc_endpoint_type = \"interface\", security_group_ids = [\"sg-<example>\"], subnet_ids = [\"subnet-<example>\"]}}"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = ""
}
