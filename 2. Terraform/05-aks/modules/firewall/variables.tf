variable "location" {
  type        = string
  description = "Location of the firewall."
}

variable "name" {
  type        = string
  description = "Name of the firewall."

  validation {
    condition     = startswith(var.name, "afw-")
    error_message = "The name of the firewall should start with 'afw-'."
  }
}

variable "public_ip_name" {
  type        = string
  description = "Name of the public IP of the firewall."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name of the firewall."
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet where the firewall will be deployed."
}
