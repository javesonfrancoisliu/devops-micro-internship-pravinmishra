variable "location" {
  type    = string
  default = "swedencentral"
}

variable "zone" {
  type    = string
  default = "1"
}

variable "project" {
  type    = string
  default = "epicbook"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2ls_v2"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "OpenSSH public key installed on both VMs"
}

variable "ssh_allowed_cidrs" {
  type        = list(string)
  description = "Source CIDRs allowed to reach SSH on the frontend VM, for example the agent public IP"

  validation {
    condition     = length(var.ssh_allowed_cidrs) > 0 && alltrue([for c in var.ssh_allowed_cidrs : can(cidrhost(c, 0))])
    error_message = "ssh_allowed_cidrs must hold at least one valid CIDR such as 203.0.113.10/32."
  }
}

variable "frontend_private_ip" {
  type    = string
  default = "10.40.1.10"
}

variable "backend_private_ip" {
  type    = string
  default = "10.40.2.10"
}

variable "mysql_server_name" {
  type        = string
  default     = "mysql-epicbook-jfl"
  description = "Globally unique MySQL flexible server name"
}

variable "mysql_sku" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "mysql_version" {
  type    = string
  default = "8.0.21"
}

variable "mysql_database" {
  type    = string
  default = "bookstore"
}

variable "mysql_admin_username" {
  type    = string
  default = "epicbookadmin"
}

variable "mysql_admin_password" {
  type      = string
  sensitive = true

  validation {
    condition     = can(regex("^[A-Za-z0-9]{16,64}$", var.mysql_admin_password))
    error_message = "mysql_admin_password must be 16 to 64 letters and digits so it is safe inside a connection URL."
  }
}
