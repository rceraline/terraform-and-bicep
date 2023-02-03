terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.41.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-cac-01"
    storage_account_name = "satfstatecac20230128"
    container_name       = "state"
    key                  = "network.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-mycompany-01"
  location = "Canada Central"
}

## VNETs
resource "azurerm_virtual_network" "hub_01" {
  name                = "vnet-hub-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub_01.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_virtual_network" "spoke_01" {
  name                = "vnet-spoke-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "spoke_01_snet_01" {
  name                 = "snet-01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke_01.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_virtual_network" "spoke_02" {
  name                = "vnet-spoke-02"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "spoke_02_snet_01" {
  name                 = "snet-01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke_02.name
  address_prefixes     = ["10.2.0.0/24"]
}

## VNET peering
resource "azurerm_virtual_network_peering" "hub_01_to_spoke_01" {
  name                      = "peer-hub-to-spoke-01"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub_01.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_01.id
}

resource "azurerm_virtual_network_peering" "spoke_01_to_hub_01" {
  name                      = "peer-spoke-01-to-hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.spoke_01.name
  remote_virtual_network_id = azurerm_virtual_network.hub_01.id
}

resource "azurerm_virtual_network_peering" "hub_01_to_spoke_02" {
  name                      = "peer-hub-to-spoke-02"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub_01.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_02.id
}

resource "azurerm_virtual_network_peering" "spoke_02_to_hub_01" {
  name                      = "peer-spoke-02-to-hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.spoke_02.name
  remote_virtual_network_id = azurerm_virtual_network.hub_01.id
}


## Azure Bastion
resource "azurerm_public_ip" "pip_01" {
  name                = "pip-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bas_01" {
  name                = "bas-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.pip_01.id
  }
}
