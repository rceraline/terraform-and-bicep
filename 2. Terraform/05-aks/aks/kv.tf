data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv_01" {
  name                        = "mycompany-kv-01"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

resource "azurerm_private_endpoint" "kv_01" {
  name                = "pe-kv-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.hub_subnets["snet-01"].id

  private_service_connection {
    name                           = "psc-kv-01"
    private_connection_resource_id = azurerm_key_vault.kv_01.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "pdzg-kv-01"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv.id]
  }
}
