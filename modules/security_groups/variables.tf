variable "aws_account_abbreviation" {
  type = string
  validation {
    condition     = length(var.aws_account_abbreviation) == 3
    error_message = "Abbreviation must be 3 letters max."
  }
  description = "3 letter aws account abbreviation"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to associate security groups with."
}

variable "security_groups" {
  type = map(
    map(any)
  )
  description = "Creates custom security groups with defined rules Eg. security_groups = { alt_web = { ingress_rules = [{from_port = 8080, to_port = 8080, protocol = \"tcp\", cidr_blocks = [10.0.0.0/8]}]}}"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to add to the security groups"
}
