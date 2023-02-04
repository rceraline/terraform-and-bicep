resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "afw" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.afwp.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_firewall_policy" "afwp" {
  name                = replace(var.name, "afw-", "afwp-")
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_firewall_policy_rule_collection_group" "afwprcg" {
  name               = replace(var.name, "afw-", "afwprcg-")
  firewall_policy_id = azurerm_firewall_policy.afwp.id
  priority           = 100

  network_rule_collection {
    name     = "collection-01"
    priority = 100
    action   = "Allow"
    rule {
      name                  = "allow-all"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.0.0.0/16", "10.1.0.0/16", "10.2.0.0/16"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}
