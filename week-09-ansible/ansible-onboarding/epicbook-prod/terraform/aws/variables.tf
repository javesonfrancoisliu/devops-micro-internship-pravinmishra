variable "region" {
  type    = string
  default = "ap-southeast-5"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "bookstore"
}

variable "db_username" {
  type    = string
  default = "epicbook"
}

variable "db_password" {
  type      = string
  sensitive = true

  validation {
    condition     = length(var.db_password) >= 16
    error_message = "db_password must be at least 16 characters."
  }
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
