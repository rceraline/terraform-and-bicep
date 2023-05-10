variable "hub_virtual_network" {
  type = object({
    name          = string
    address_space = list(string)
    subnets = map(object({
      address_prefixes = list(string)
    }))
  })
}

variable "spoke_virtual_networks" {
  type = map(object({
    address_space = list(string)
  }))
}

variable "spoke_subnets" {
  type = map(object({
    vnet_name        = string
    subnet_name      = string
    address_prefixes = list(string)
  }))
}

variable "route_tables" {
  type = map(object({
    name           = string
    address_prefix = string
  }))
}

variable "route_table_associations" {
  type = list(object({
    route_table_name = string
    vnet_name        = string
    subnet_name      = string
  }))
}
