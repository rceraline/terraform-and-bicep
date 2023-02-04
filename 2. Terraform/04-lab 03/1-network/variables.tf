variable "hub_virtual_network" {
  type = object({
    name          = string
    address_space = list(string)
    subnets = map(object({
      address_prefixes = list(string)
    }))
  })
}

variable "route_tables" {
  type = map(object({
    vnet = string
    routes = map(object({
      address_prefix = string
    }))
  }))
}

variable "spoke_virtual_networks" {
  type = map(object({
    address_space = list(string)
    subnets = map(object({
      address_prefix = string
    }))
  }))
}
