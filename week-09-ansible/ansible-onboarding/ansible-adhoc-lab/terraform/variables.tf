variable "region" {
  type    = string
  default = "ap-southeast-5"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "server_roles" {
  type    = set(string)
  default = ["web", "app", "db"]
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519_ansible.pub"
}

variable "controller_ip" {
  type = string

  validation {
    condition     = can(cidrhost("${var.controller_ip}/32", 0))
    error_message = "controller_ip must be a single IPv4 address such as 203.0.113.10."
  }
}
