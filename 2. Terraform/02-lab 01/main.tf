terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.41.0"
    }
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

## Virtual machine
resource "azurerm_network_interface" "nic_01" {
  name                = "nic-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke_01_snet_01.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm_01" {
  name                = "vm-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic_01.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
