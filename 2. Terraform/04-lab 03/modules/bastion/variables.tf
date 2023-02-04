variable "location" {
  type        = string
  description = "Location of the bastion."
}

variable "name" {
  type        = string
  description = "Name of the bastion."
}

variable "public_ip_name" {
  type        = string
  description = "Name of the public IP of the bastion."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name of the bastion."
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet where the bastion will be deployed."
}
