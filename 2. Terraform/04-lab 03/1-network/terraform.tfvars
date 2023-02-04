hub_virtual_network = {
  name          = "vnet-hub-01"
  address_space = ["10.0.0.0/16"]
  subnets = {
    "AzureBastionSubnet" = {
      address_prefixes = ["10.0.2.0/24"]
    }
    "AzureFirewallSubnet" = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}

route_tables = {
  "rt-01" = {
    routes = {
      "to-spoke-02" = {
        address_prefix = "10.2.0.0/16"
      }
    }
    vnet = "vnet-spoke-01"
  }
  "rt-02" = {
    routes = {
      "to-spoke-01" = {
        address_prefix = "10.1.0.0/16"
      }
    }
    vnet = "vnet-spoke-02"
  }
}

spoke_virtual_networks = {
  "vnet-spoke-01" = {
    address_space = ["10.1.0.0/16"]
    subnets = {
      "snet-01" = {
        address_prefix = "10.1.0.0/24"
      }
    }
  }
  "vnet-spoke-02" = {
    address_space = ["10.2.0.0/16"]
    subnets = {
      "snet-01" = {
        address_prefix = "10.2.0.0/24"
      }
    }
  }
}
