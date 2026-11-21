variable "location" {
  type    = string
  default = "eastasia"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2ls_v2"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
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
