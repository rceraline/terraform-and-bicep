## DNS
resource "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.canadacentral.azmk8s.io"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "cr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "mycompany" {
  name                = "mycompany.com"
  resource_group_name = azurerm_resource_group.rg.name
}

## DNS Links
resource "azurerm_private_dns_zone_virtual_network_link" "aks_hub" {
  name                  = "link-aks-hub"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks_spokes" {
  for_each              = { for spoke in azurerm_virtual_network.spokes : spoke.name => spoke.id }
  name                  = "link-aks-${each.key}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = each.value
}

resource "azurerm_private_dns_zone_virtual_network_link" "cr_hub" {
  name                  = "link-cr-hub"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.cr.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "cr_spokes" {
  for_each              = { for spoke in azurerm_virtual_network.spokes : spoke.name => spoke.id }
  name                  = "link-cr-${each.key}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.cr.name
  virtual_network_id    = each.value
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_hub" {
  name                  = "link-kv-hub"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_spokes" {
  for_each              = { for spoke in azurerm_virtual_network.spokes : spoke.name => spoke.id }
  name                  = "link-kv-${each.key}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = each.value
}

resource "azurerm_private_dns_zone_virtual_network_link" "mycompany_hub" {
  name                  = "link-mycompany-hub"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mycompany.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "mycompany_spokes" {
  for_each              = { for spoke in azurerm_virtual_network.spokes : spoke.name => spoke.id }
  name                  = "link-mycompany-${each.key}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mycompany.name
  virtual_network_id    = each.value
}
