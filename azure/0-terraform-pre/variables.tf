variable "prefix" {
  type        = string
  description = "This prefix will be included in the name of most resources."
}

variable "location" {
  type        = string
  description = "Azure region where the resources are created."
}

variable "department" {
  description = "Value for the department tag."
  type        = string
  default     = "PlatformEng"
}

variable "env" {
  type        = string
  description = "Value for the environment tag."
}