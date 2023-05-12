resource "azurerm_container_registry" "cr_01" {
  name                          = "cr20230512"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
}

resource "azurerm_private_endpoint" "cr_01" {
  name                = "pr-cr-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.hub_subnets["snet-01"].id

  private_service_connection {
    name                           = "psc-cr-01"
    private_connection_resource_id = azurerm_container_registry.cr_01.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "pdzg-cr-01"
    private_dns_zone_ids = [azurerm_private_dns_zone.cr.id]
  }
}
