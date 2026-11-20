variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "ssh_allowed_cidr" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}
