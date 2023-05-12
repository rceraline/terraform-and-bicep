resource "azurerm_public_ip" "pip_03" {
  name                = "pip-03"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name              = "agw-01-beap"
  frontend_port_name                     = "agw-01-feport"
  frontend_ip_configuration_name         = "agw-01-feip"
  private_frontend_ip_configuration_name = "agw-01-private-feip"
  http_setting_name                      = "agw-01-be-htst"
  listener_name                          = "agw-01-httplstn"
  request_routing_rule_name              = "agw-01-rqrt"
  redirect_configuration_name            = "agw-01-rdrcfg"
}

resource "azurerm_application_gateway" "agw_01" {
  name                = "agw-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.spoke_subnets["vnet-spoke-01_snet-01"].id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip_03.id
  }

  frontend_ip_configuration {
    name                          = local.private_frontend_ip_configuration_name
    private_ip_address            = "10.1.0.4"
    private_ip_address_allocation = "Static"
    subnet_id                     = azurerm_subnet.spoke_subnets["vnet-spoke-01_snet-01"].id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 1
  }

  ##ignore changes since AGW is managed by AGIC
  lifecycle {
    ignore_changes = [
      tags,
      backend_address_pool,
      backend_http_settings,
      frontend_port,
      http_listener,
      probe,
      redirect_configuration,
      request_routing_rule,
      ssl_certificate
    ]
  }
}
