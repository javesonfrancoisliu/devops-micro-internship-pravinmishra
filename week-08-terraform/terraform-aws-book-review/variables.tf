variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "repo_url" {
  type = string
}

variable "web_instance_type" {
  type = string
}

variable "app_instance_type" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_backup_retention_days" {
  type    = number
  default = 1
}

variable "db_skip_final_snapshot" {
  type    = bool
  default = false
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "db_name" {
  type = string
}
