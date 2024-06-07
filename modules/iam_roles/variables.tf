variable "account_abbreviation" {
  type = string
  validation {
    condition     = length(var.account_abbreviation) == 3
    error_message = "Abbreviation must be 3 letters max."
  }
  description = "3 letter aws account abbreviation"
}

variable "name" {
  type        = string
  description = "Unique portion of iam policy name. The name is prefixed with account abbreviation, global, iam_policy. Eg. sbx-global-iam_role-<name>"
}

variable "assume_role_policy" {
  type        = string
  description = "The policy that grants an entity permission to assume the role."
}
variable "force_detach_policies" {
  type        = bool
  default     = true
  description = "Specifies to force detaching any policies the role has before destroying it."
}

variable "path" {
  type        = string
  default     = null
  description = "The path to the role."
}

variable "description" {
  type        = string
  default     = null
  description = "The description of the role."
}

variable "max_session_duration" {
  type        = number
  default     = 10800
  description = "The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours."
}

variable "permissions_boundary" {
  type        = string
  default     = null
  description = "The ARN of the policy that is used to set the permissions boundary for the role."
}

variable "role_policy_arns" {
  type        = set(string)
  default     = []
  description = "List of policy ARNs to be attached to the role."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to add to the role."
}

variable "instance_profile" {
  type        = bool
  default     = false
  description = "When enabled makes the role an ec2 instance profile"
}
