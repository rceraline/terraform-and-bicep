hub_virtual_network = {
  name          = "vnet-hub"
  address_space = ["10.0.0.0/16"]
  subnets = {
    "AzureBastionSubnet" = {
      address_prefixes = ["10.0.2.0/24"]
    }
    "AzureFirewallSubnet" = {
      address_prefixes = ["10.0.1.0/24"]
    }
    "snet-01" = {
      address_prefixes = ["10.0.3.0/24"]
    }
  }
}

spoke_virtual_networks = {
  "vnet-spoke-01" = {
    address_space = ["10.1.0.0/16"]
  }
  "vnet-spoke-02" = {
    address_space = ["10.2.0.0/16"]
  }
}

spoke_subnets = {
  "vnet-spoke-01_snet-01" = {
    vnet_name        = "vnet-spoke-01"
    subnet_name      = "snet-01"
    address_prefixes = ["10.1.0.0/24"]
  },
  "vnet-spoke-01_snet-02" = {
    vnet_name        = "vnet-spoke-01"
    subnet_name      = "snet-02"
    address_prefixes = ["10.1.1.0/24"]
  },
  "vnet-spoke-02_snet-01" = {
    vnet_name        = "vnet-spoke-02"
    subnet_name      = "snet-01"
    address_prefixes = ["10.2.0.0/24"]
  },
}

route_tables = {
  "rt-01" = {
    name           = "to-spoke-02"
    address_prefix = "10.2.0.0/16"
  }
  "rt-02" = {
    name           = "to-spoke-01"
    address_prefix = "10.1.0.0/16"
  }
}

route_table_associations = [
  {
    route_table_name = "rt-01"
    vnet_name        = "vnet-spoke-01"
    subnet_name      = "snet-01"
  },
  {
    route_table_name = "rt-01"
    vnet_name        = "vnet-spoke-01"
    subnet_name      = "snet-02"
  },
  {
    route_table_name = "rt-02"
    vnet_name        = "vnet-spoke-02"
    subnet_name      = "snet-01"
  }
]
