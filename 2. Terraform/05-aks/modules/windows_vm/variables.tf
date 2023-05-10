variable "location" {
  type        = string
  description = "Location of the virtual machine."
}

variable "install_iis" {
  type        = bool
  description = "Determine if IIS should be install or not."
  default     = false
}

variable "name" {
  type        = string
  description = "Name of the virtual machine"

  validation {
    condition     = startswith(var.name, "vm-")
    error_message = "The name of the virtual machine should start with 'vm-'."
  }
}

variable "password" {
  type        = string
  description = "User account password of the virtual machine."
  sensitive   = true
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name of the virtual machine."
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet where the virtual machine will be deployed."
}
