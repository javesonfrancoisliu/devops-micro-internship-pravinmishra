variable "name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "internal_alb_dns" {
  type = string
}

variable "public_alb_dns" {
  type = string
}

variable "vpc_resolver_ip" {
  type = string
}

variable "repo_url" {
  type = string
}
