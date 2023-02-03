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
    key                  = "compute.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
  }
}

data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-tfstate-cac-01"
    storage_account_name = "satfstatecac20230128"
    container_name       = "state"
    key                  = "network.terraform.tfstate"
  }
}

data "azurerm_resource_group" "rg" {
  name = "rg-mycompany-01"
}

## VM 01
resource "azurerm_network_interface" "nic_01" {
  name                = "nic-01"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.network.outputs.spoke_01_snet_01_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm_01" {
  name                = "vm-01"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = var.vm_password
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

## VM 02
resource "azurerm_network_interface" "nic_02" {
  name                = "nic-02"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.network.outputs.spoke_02_snet_01_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm_02" {
  name                = "vm-02"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = var.vm_password
  network_interface_ids = [
    azurerm_network_interface.nic_02.id,
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

## IIS
resource "azurerm_virtual_machine_extension" "iis" {
  name                 = "iis"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm_02.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
 {
  "commandToExecute": "powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"
 }
SETTINGS
}
