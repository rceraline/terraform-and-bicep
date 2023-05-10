## VNETs
resource "azurerm_virtual_network" "hub" {
  name                = var.hub_virtual_network.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.hub_virtual_network.address_space
}

resource "azurerm_subnet" "hub_subnets" {
  for_each = var.hub_virtual_network.subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_virtual_network" "spokes" {
  for_each = var.spoke_virtual_networks

  name                = each.key
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = each.value.address_space
}

resource "azurerm_subnet" "spoke_subnets" {
  for_each = var.spoke_subnets

  name                 = each.value.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = each.value.address_prefixes

  depends_on = [azurerm_virtual_network.spokes]
}

## VNET peering
resource "azurerm_virtual_network_peering" "hub_to_spokes" {
  for_each = { for vnet in azurerm_virtual_network.spokes : vnet.name => vnet.id }

  name                      = "peer-hub-to-${replace(each.key, "vnet-", "")}"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = each.value
}

resource "azurerm_virtual_network_peering" "spokes_to_hub" {
  for_each = { for vnet in azurerm_virtual_network.spokes : vnet.name => vnet.id }

  name                      = "peer-${replace(each.key, "vnet-", "")}-to-hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = each.key
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}

## Azure Bastion
module "bastion" {
  source = "../modules/bastion"

  location            = azurerm_resource_group.rg.location
  name                = "bas-01"
  public_ip_name      = "pip-01"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.hub_subnets["AzureBastionSubnet"].id
}

## Azure Firewall
module "firewall" {
  source = "../modules/firewall"

  location            = azurerm_resource_group.rg.location
  name                = "afw-01"
  public_ip_name      = "pip-02"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.hub_subnets["AzureFirewallSubnet"].id
}

## Route Tables
resource "azurerm_route_table" "route_tables" {
  for_each = var.route_tables

  name                          = each.key
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name                   = each.value.name
    address_prefix         = each.value.address_prefix
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = module.firewall.private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "spokes" {
  for_each = { for association in var.route_table_associations : "${association.vnet_name}_${association.subnet_name}" => association.route_table_name }

  subnet_id      = azurerm_subnet.spoke_subnets[each.key].id
  route_table_id = azurerm_route_table.route_tables[each.value].id
}
