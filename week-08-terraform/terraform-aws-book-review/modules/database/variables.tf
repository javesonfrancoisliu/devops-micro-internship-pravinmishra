variable "name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "backup_retention_days" {
  type = number
}

variable "skip_final_snapshot" {
  type = bool
}

variable "deletion_protection" {
  type = bool
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}
