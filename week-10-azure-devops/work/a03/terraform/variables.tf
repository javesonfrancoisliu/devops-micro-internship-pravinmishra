variable "region" {
  type    = string
  default = "ap-southeast-5"
}

variable "aws_profile" {
  type    = string
  default = "javesonpersonal"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "name_prefix" {
  type    = string
  default = "dmi-week10-react"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa_dmi_azdo.pub"
}

variable "controller_ip" {
  type = string

  validation {
    condition     = can(cidrhost("${var.controller_ip}/32", 0))
    error_message = "controller_ip must be a single IPv4 address such as 203.0.113.10."
  }
}

variable "agent_ip" {
  type = string

  validation {
    condition     = can(cidrhost("${var.agent_ip}/32", 0))
    error_message = "agent_ip must be a single IPv4 address such as 203.0.113.10."
  }
}
